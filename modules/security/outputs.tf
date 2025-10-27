output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "ec2_iam_role_name" {
  description = "IAM role name for EC2 instances"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}