variable "project_name" {
  type        = string
  description = "Name of project"
  default     = "tf-test"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "pub_subnets_id" {
  type        = list(any)
  description = "Public Subnets ID"
}

variable "priv_subnets_id" {
  type        = list(any)
  description = "Private Subnets ID"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile for Healh Check Sever"
}

variable "health_service_endpoints" {
  type        = string
  description = "Endpoints to check health for"
  default     = "https://google.com"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topic ARN"
}
