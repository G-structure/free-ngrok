terraform {
  backend "s3" {
    bucket         = "terraform-state-73cea43c7d6aa30e" # Replace with your bucket name
    key            = "state-management/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock-73cea43c7d6aa30e" # Replace with your table name
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.state_bucket_prefix}-${random_id.suffix.hex}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.state_table_prefix}-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "state_bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  default     = "terraform-state"
}

variable "state_table_prefix" {
  description = "Prefix for the DynamoDB table name"
  default     = "terraform-state-lock"
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}
