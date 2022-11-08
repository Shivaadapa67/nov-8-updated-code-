terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN

/*provider "aws" {
  default_tags {
    tags = {
      iac_environment = var.iac_environment_tag
    }
  }
}*/

