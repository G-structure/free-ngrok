terraform {
  backend "s3" {
    bucket         = "terraform-state-73cea43c7d6aa30e" # Replace with your bucket name
    key            = "oidc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock-73cea43c7d6aa30e" # Replace with your table name
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to create"
}

variable "role_name" {
  description = "The name of the IAM role for GitHub Actions"
  default     = "github-actions-oidc-role"
}

variable "repositories" {
  description = "List of GitHub repositories to grant access to"
  type        = list(string)
}

provider "aws" {
  region = var.aws_region
}

# aws account id
data "aws_caller_identity" "current" {}


resource "random_id" "suffix" {
  byte_length = 8
}


# create policy
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy-${random_id.suffix.hex}"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # EC2 permissions for AMI creation
          "ec2:*",

          # S3 permissions for storing AMIs
          "s3:*",

          # dynamodb permissions for state management
          "dynamodb:*",

          # iam permissions for role creation
          "iam:*",


        ]
        Resource = [
          # EC2 resources
          "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",

          # S3 bucket resources
          "arn:aws:s3:::*",

          # dynamodb table resources
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*",

          # iam role resources
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*",
        ]
      }
    ]
  })
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"
  # create_oidc_provider = true
  create_oidc_provider = false
  oidc_provider_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  create_oidc_role     = true
  role_name            = "github-oidc-role-${random_id.suffix.hex}"

  repositories = var.repositories

  oidc_role_attach_policies = [
    aws_iam_policy.github_actions.arn
  ]
}

################################################################################
# OUTPUTS
################################################################################
output "github_oidc_role_arn" {
  description = "CICD GitHub role."
  value       = module.github-oidc.oidc_role
}
