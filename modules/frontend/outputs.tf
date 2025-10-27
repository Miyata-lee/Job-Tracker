# File: modules/storage/outputs.tf
# Purpose: Export S3 and CloudFront information

output "s3_frontend_bucket_name" {
  description = "S3 frontend bucket name"
  value       = aws_s3_bucket.frontend.id
}

output "s3_frontend_bucket_arn" {
  description = "S3 frontend bucket ARN"
  value       = aws_s3_bucket.frontend.arn
}

output "s3_logs_bucket_name" {
  description = "S3 logs bucket name"
  value       = aws_s3_bucket.logs.id
}

output "s3_logs_bucket_arn" {
  description = "S3 logs bucket ARN"
  value       = aws_s3_bucket.logs.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "oai_iam_arn" {
  description = "CloudFront OAI IAM ARN"
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}