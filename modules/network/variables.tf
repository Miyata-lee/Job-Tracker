variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1 (us-east-1a)"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2 (us-east-1b)"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 (us-east-1a)"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 (us-east-1b)"
  type        = string
}