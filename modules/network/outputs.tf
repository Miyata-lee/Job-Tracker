output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 ID (us-east-1a)"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 ID (us-east-1b)"
  value       = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  description = "Private Subnet 1 ID (us-east-1a)"
  value       = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "Private Subnet 2 ID (us-east-1b)"
  value       = aws_subnet.private_2.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private.id
}