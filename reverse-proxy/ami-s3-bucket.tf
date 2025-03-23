

# random suffix for resources
resource "random_id" "suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "amis" {
  bucket = "amis-k3s-${random_id.suffix.dec}"

  tags = {
    Name        = "AMIs Bucket"
    Environment = "Production"
    Managed_by  = "Terraform"
  }
}

# Instead of ACL, use Object Ownership
resource "aws_s3_bucket_ownership_controls" "amis_ownership" {
  bucket = aws_s3_bucket.amis.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "amis_versioning" {
  bucket = aws_s3_bucket.amis.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "amis_encryption" {
  bucket = aws_s3_bucket.amis.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "amis_public_access_block" {
  bucket = aws_s3_bucket.amis.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "ami_bucket_name" {
  description = "The name of the S3 bucket storing AMIs"
  value       = aws_s3_bucket.amis.id
}