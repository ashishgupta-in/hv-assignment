output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "pub_subnets_id" {
  value       = module.vpc.pub_subnets_id
  description = "Public Subnets"
}

output "priv_subnets_id" {
  value       = module.vpc.priv_subnets_id
  description = "Private Subnets"
}

output "ami_id" {
  value       = module.ec2.ami_id
  description = "Instance AMI"
}

output "static_web_ip" {
  value       = module.ec2.static_web_ip
  description = "Static web server IP Address"
}

output "static_web_dns" {
  value       = module.ec2.static_web_dns
  description = "Static web server DNS Hostname"
}

output "sns_topic_arn" {
  value       = module.sns.sns_topic_arn
  description = "Health Check SNS Topic ARN"
}
