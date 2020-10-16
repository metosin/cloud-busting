# State file will be stored in this bucket
resource "aws_s3_bucket" "terraform" {
  bucket = "${var.prefix}-terraform"

  acl = "private"

  versioning {
    enabled = true
  }

  tags = {
    Prefix    = var.prefix
    Terraform = "true"
  }
}

# State file will be encrypted with this key
resource "aws_kms_key" "terraform" {
  description = "Key for encrypting Terraform state files"
}

resource "aws_kms_alias" "terraform" {
  name          = "alias/${var.prefix}-terraform"
  target_key_id = aws_kms_key.terraform.key_id
}

# Deny writes without KMS encyption
resource "aws_s3_bucket_policy" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "PutObjPolicy"
    Statement = [
      {
        Sid       = "DenyIncorrectEncryptionHeader"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      }
    ]
  })

}

# Objects in this bucket will be private
resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.terraform
  ]
}

# State file modifications are protected via a lock in DynamoDB table
resource "aws_dynamodb_table" "terraform" {
  name = "${var.prefix}-terraform"

  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
}
