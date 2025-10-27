variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name dev"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "jobtracker"
}

# VPC and Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1 (us-east-1a)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2 (us-east-1b)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 (us-east-1a)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 (us-east-1b)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro for free tier)"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}
variable "desired_capacity" {
  description = "Desired number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 3
}


variable "db_instance_class" {
  description = "RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "jobtracker_dev"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password (sensitive)"
  type        = string
  sensitive   = true
}

variable "db_storage_allocated" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}