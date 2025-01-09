resource "aws_s3_bucket" "amis" {
  bucket = "amis-k3s-1f567871bd52790f"

  # Tags are recommended in modern configurations
  tags = {
    Name        = "AMIs Bucket"
    Environment = "Production"
    Managed_by  = "Terraform"
  }
}

# Separate ACL resource
resource "aws_s3_bucket_acl" "amis_acl" {
  bucket = aws_s3_bucket.amis.id
  acl    = "private"
}

# Separate versioning resource
resource "aws_s3_bucket_versioning" "amis_versioning" {
  bucket = aws_s3_bucket.amis.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Separate encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "amis_encryption" {
  bucket = aws_s3_bucket.amis.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Optional but recommended: Block public access
resource "aws_s3_bucket_public_access_block" "amis_public_access_block" {
  bucket = aws_s3_bucket.amis.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "amis_bucket_name" {
  value = aws_s3_bucket.amis.id
}