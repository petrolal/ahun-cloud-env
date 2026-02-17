output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "lambda_name" {
  value = module.lambda_scheduler.lambda_name
}
