output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 ID (us-east-1a)"
  value       = module.network.public_subnet_1_id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 ID (us-east-1b)"
  value       = module.network.public_subnet_2_id
}

output "private_subnet_1_id" {
  description = "Private Subnet 1 ID (us-east-1a)"
  value       = module.network.private_subnet_1_id
}

output "private_subnet_2_id" {
  description = "Private Subnet 2 ID (us-east-1b)"
  value       = module.network.private_subnet_2_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.compute.alb_arn
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = module.compute.target_group_arn
}


output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_name
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_arn
}

output "rds_endpoint" {
  description = "RDS database endpoint (host:port)"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.database.db_name
}

output "rds_master_username" {
  description = "RDS master username"
  value       = module.database.db_username
  sensitive   = true
}

# Security Outputs
output "alb_security_group_id" {
  description = "Security Group ID for ALB"
  value       = module.security.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "Security Group ID for EC2"
  value       = module.security.ec2_security_group_id
}

output "rds_security_group_id" {
  description = "Security Group ID for RDS"
  value       = module.security.rds_security_group_id
}

# IAM Outputs
output "ec2_iam_role_name" {
  description = "IAM role name for EC2 instances"
  value       = module.security.ec2_iam_role_name
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  value       = module.security.ec2_instance_profile_name
}