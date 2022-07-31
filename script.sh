#!/bin/bash

# Terraform Variable File
INPUT_FILE='./terraform/terraform.tfvars'

# Take User Input
read -p "Enter Project Name : " project_name
read -p "Enter Region Name : " region
read -sp "Enter Access Key : " access_key && echo ''
read -sp "Enter Secret Key : " secret_key && echo ''
read -p "Enter Health Endpoint To Check For: " endpoint
read -p "Enter Email : " email
read -p "Enter Number Of Availability Zone  : " az_count

# Write Input To File
sed -i "s+project_name = \"\"+project_name = \"$project_name\"+" $INPUT_FILE
sed -i "s+region       = \"\"+region       = \"$region\"+" $INPUT_FILE
sed -i "s+access_key   = \"\"+access_key   = \"$access_key\"+" $INPUT_FILE
sed -i "s+secret_key   = \"\"+secret_key   = \"$secret_key\"+" $INPUT_FILE
sed -i "s+health_service_endpoints = \"\"+health_service_endpoints = \"$endpoint\"+" $INPUT_FILE
sed -i "s+subscription_email = \"\"+subscription_email = \"$email\"+" $INPUT_FILE
sed -i "s+availability_zone_count = 0\"\"+availability_zone_count = \"$az_count\"+" $INPUT_FILE

# Terraform Deployment
cd terraform 
terraform init
terraform apply -json -auto-approve >> ../deployment-log.txt
terraform output >> ../output-log.txt