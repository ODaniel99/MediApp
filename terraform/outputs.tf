output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb_sg.id
}

output "backend_security_group_id" {
  description = "The ID of the backend security group."
  value       = aws_security_group.backend_sg.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "backend_target_group_arn" {
  description = "The ARN of the backend target group."
  value       = aws_lb_target_group.backend.arn
}

output "backend_asg_name" {
  description = "The name of the backend Auto Scaling Group."
  value       = aws_autoscaling_group.backend.name
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB global table."
  value       = aws_dynamodb_table.main.name
}

output "media_s3_bucket_name" {
  description = "The name of the S3 bucket for media storage."
  value       = aws_s3_bucket.media_bucket.id
}

output "frontend_s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend website."
  value       = aws_s3_bucket.frontend_bucket.id
}

output "cloudfront_distribution_domain" {
  description = "The domain name of the CloudFront distribution for the frontend."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "media_s3_bucket_replica_name" {
  description = "The name of the replica S3 bucket for media storage."
  value       = aws_s3_bucket.media_bucket_replica.id
}

output "frontend_s3_bucket_replica_name" {
  description = "The name of the replica S3 bucket for the frontend website."
  value       = aws_s3_bucket.frontend_bucket_replica.id
}

output "terraform_state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_lock_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}

output "application_secrets_arn" {
  description = "The ARN of the placeholder for application secrets in Secrets Manager."
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "frontend_deploy_role_arn" {
  description = "The ARN of the IAM role for frontend deployment."
  value       = aws_iam_role.frontend_deploy_role.arn
}

output "backend_deploy_role_arn" {
  description = "The ARN of the IAM role for backend deployment."
  value       = aws_iam_role.backend_deploy_role.arn
}
