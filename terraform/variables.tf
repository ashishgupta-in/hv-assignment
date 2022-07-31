# ----------------------------------------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------------------- #
# Environment config
variable "project_name" {
  type        = string
  description = "Name of project"
  default     = "tf-test"
}

variable "access_key" {
  type        = string
  description = "Access Key"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "secret Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region"
  sensitive   = true
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------------------- #
# VPC required variables
variable "cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "enable_dns_support" {
  type        = bool
  description = "Set to true to enable DNS Support"
  default     = "true"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Set to true tp enable DNS Hostnames"
  default     = "true"
}

variable "availability_zone_count" {
  type        = number
  description = "Count of AZs for the Subnet"
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------------------- #
# EC2 required variables
variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "health_service_endpoints" {
  type        = string
  description = "Endpoints to check health for"
  default     = "https://google.com"
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------------------- #
# SNS required variables
variable "subscription_email" {
  type        = string
  description = "Subscription for Health Check Status"
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------------------- #
