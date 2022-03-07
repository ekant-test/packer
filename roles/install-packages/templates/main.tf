data "aws_caller_identity" "this" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
locals {
  account_id = data.aws_caller_identity.this.account_id
  account    = var.accounts[local.account_id]
  partition  = local.account.production ? "prd" : "npr"
}
