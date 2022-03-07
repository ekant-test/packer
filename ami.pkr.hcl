# -- Required AMI parameters ---------------------------------------------------

variable "subnet_id" {
  type        = string
  description = "Subnet ID in which the instance will be created"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}

locals {
  # timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  timestamp = formatdate("DD/MMM/YYYY/hh.mm ZZZ", timestamp())
}

# -- build pipeline ------------------------------------------------------------

source "amazon-ebs" "vm" {
  ami_name      = "ami-(${local.timestamp})"
  instance_type = "${var.instance_type}"
  subnet_id     = "${var.subnet_id}"
  ssh_username  = "ec2-user"
  # When using session_manager the machine running Packer must have the AWS Session Manager Plugin installed and within the users'
  # system path. Connectivity via the session_manager interface establishes a secure tunnel between the local host and the remote
  # host on an available local port to the specified ssh_port.(https://www.packer.io/plugins/builders/amazon/ebs#session-manager-connections)
  ssh_interface = "session_manager"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  # Creates a temporary instance profile policy document to grant Systems Manager permissions to the Ec2 instance.
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ]
      Resource = ["*"]
    }
  }
}

build {
  name = "ami"
  source "source.amazon-ebs.vm" {
  }
  provisioner "ansible" {
    playbook_file = "build.yml"
    extra_arguments = [
      "-vv"
    ]
  }
  # Create manifest.json file to add the output from the packer.
  post-processor "shell-local" {
    command = "touch manifest.json"
  }
  # The manifest post-processor writes a JSON file with a list of all of the artifacts packer produces during a run.
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
  # Run the shell script to read the JSON file and extract the AMI id which will then be stored in SSM parameter store.
  # Also will delete the manifest.json file which is no longer needed.
  post-processor "shell-local" {
    script = "./ssm.sh"
  }
}
