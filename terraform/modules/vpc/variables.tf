variable "project_name" {
  type        = string
  description = "Name of project"
  default     = "tf-test"
}

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
