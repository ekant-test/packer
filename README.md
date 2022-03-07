## Ec2 AMI for Applcation

This project creates AMI golden Image which will be used as a base AMI.

This Playbook performs the following

* Pulls the latest AMAZON AMI 2 from the AWS.
* Provisions the AMI by running an Ansible Playbook to install tools.
* Add the AMI ID in SSM paramater store.


## Pre-requisites

1. Roles to be used for instalation and configuration of application.

2. Install SSM plugin manager on the local machine For Mac. Connectivity via the session_manager interface establishes a secure tunnel between the local host and the remote host on an available local port to the specified ssh_port.(https://www.packer.io/plugins/builders/amazon/ebs#session-manager-connections)

[For other OS](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

To install the Session Manager plugin using the bundled installer (macOS)

Download the bundled installer.

curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
Unzip the package.

unzip sessionmanager-bundle.zip
Run the install command.

sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
Note
The plugin requires either Python 2.6.5 or later, or Python 3.3 or later. By default, the install script runs under the system default version of Python. If you have installed an alternative version of Python and want to use that to install the Session Manager plugin, run the install script with that version by absolute path to the Python executable. The following is an example.

sudo /usr/local/bin/python3.6 sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
The installer installs the Session Manager plugin at /usr/local/sessionmanagerplugin and creates the symlink session-manager-plugin in the /usr/local/bin directory. This eliminates the need to specify the install directory in the user's $PATH variable.

To see an explanation of the -i and -b options, use the -h option.

./sessionmanager-bundle/install -h
Verify that the installation was successful. For information, see Verify the Session Manager plugin installation.

Note
If you ever want to uninstall the plugin, run the following two commands in the order shown.

sudo rm -rf /usr/local/sessionmanagerplugin
sudo rm /usr/local/bin/session-manager-plugin


## Usage

Login to AWS Account.

Packer init and validate

```sh
make clean
```

Packer build

```sh
make build
```
