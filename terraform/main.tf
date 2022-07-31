# ----------------------------------------------------------------------------------------------------------------------------------- #
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# Provider AWS
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# VPC
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name

  cidr_block              = var.cidr_block
  enable_dns_support      = var.enable_dns_support
  enable_dns_hostnames    = var.enable_dns_hostnames
  availability_zone_count = var.availability_zone_count
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# IAM
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# SNS
module "sns" {
  source = "./modules/sns"

  project_name       = var.project_name
  subscription_email = var.subscription_email
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
# EC2
module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name

  vpc_id                   = module.vpc.vpc_id
  vpc_cidr_block           = var.cidr_block
  pub_subnets_id           = module.vpc.pub_subnets_id
  priv_subnets_id          = module.vpc.priv_subnets_id
  iam_instance_profile     = module.iam.iam_instance_profile
  sns_topic_arn            = module.sns.sns_topic_arn
  health_service_endpoints = var.health_service_endpoints

  depends_on = [module.vpc, module.sns, module.iam]
}

# ----------------------------------------------------------------------------------------------------------------------------------- #
