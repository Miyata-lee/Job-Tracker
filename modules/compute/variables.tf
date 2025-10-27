variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
}

variable "min_capacity" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of instances"
  type        = number
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Public subnet 1 ID (us-east-1a)"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Public subnet 2 ID (us-east-1b)"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group ID for ALB"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security Group ID for EC2"
  type        = string
}

variable "ec2_iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}