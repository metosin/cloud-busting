output "kms_key_id" {
  value = aws_kms_key.terraform.arn
}

output "dynamodb_table" {
  value = aws_dynamodb_table.terraform.name
}

output "state_bucket" {
  value = aws_s3_bucket.terraform.id
}
