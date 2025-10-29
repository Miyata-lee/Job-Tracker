variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}
variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type = string
}