output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "pub_subnets_id" {
  value       = [for sub in aws_subnet.public : sub.id]
  description = "Public Subnets ID"
}

output "priv_subnets_id" {
  value       = [for sub in aws_subnet.private : sub.id]
  description = "Private Subnets ID"
}
