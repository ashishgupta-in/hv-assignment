# Amazon Linux AMI for the region
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Static server for instance details
resource "aws_instance" "static_web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.pub_subnets_id, 0)
  vpc_security_group_ids      = [aws_security_group.static_web_sg.id]
  associate_public_ip_address = true

  user_data = filebase64("${path.module}/static-web-script.sh")

  tags       = { Name = "${var.project_name}-static-server" }
  depends_on = [aws_security_group.static_web_sg]
}

# Security Group for static web server
resource "aws_security_group" "static_web_sg" {
  name   = "${var.project_name}-static-web-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-static-web-sg", Description = "Allow HTTP & HTTPS" }
}

# Health check service server
resource "aws_instance" "health_check_service" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.priv_subnets_id, 0)
  vpc_security_group_ids      = [aws_security_group.health_check_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile

  user_data = <<DO
#!/bin/bash

# Get updates and install required services
yum update -y
yum install -y python3
pip3 install requests
pip3 install boto3

mkdir /home/scripts

echo ${var.health_service_endpoints} > /home/scripts/config.csv 

tee /home/scripts/main.py <<KO
import requests
import csv
import boto3
import json

sns = boto3.client('sns')


def publish_message(url, state, status):
    message = {"URL": url, "State": state, "Status": str(status)}
    response = sns.publish(
        TargetArn="arn:aws:sns:us-west-2:368355641188:reminant-health-status-topic",
        Message=json.dumps({'default': json.dumps(message)}),
        Subject='Health Check Failed',
        MessageStructure='json'
    )


def main():
    config_file = open('/home/scripts/config.csv')
    csvreader = csv.reader(config_file)
    for url in csvreader:
        try:
            response = requests.get(url[0])
            state = "Healthy"
            status = response.status_code
            if str(response.status_code).startswith("4") or str(response.status_code).startswith("5"):
                state = "Unhealthy"
                status = "Client Error" if str(
                    response.status_code).startswith("4") else "Server Error"
                publish_message(url, state, status)
        except Exception as e:
            state = "Unhealthy"
            status = str(e)
            publish_message(url, "Unhealthy", status)
        finally:
            print("URL : {}\nState : {}\nStatus : {}".format(
                url, state, status))


main()

KO


tee /home/scripts/script.sh <<PO
#!/bin/bash

echo `date`
export AWS_DEFAULT_REGION=$(ec2-metadata --availability-zone | sed 's/.$//' | sed 's/placement: //')
python3 /home/scripts/main.py

PO

chmod 775 /home/scripts/main.py
chmod 775 /home/scripts/script.sh

crontab -l > cron_bkp
echo "*/10 * * * * /home/scripts/script.sh >/dev/null 2>&1" >> cron_bkp
crontab cron_bkp
rm cron_bkp

DO

  tags       = { Name = "${var.project_name}-health-check-server" }
  depends_on = [aws_security_group.health_check_sg]
}

# Security Group for health check service server
resource "aws_security_group" "health_check_sg" {
  name   = "${var.project_name}-health-check-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-health_check_sg", Description = "Allow internal traffic" }
}
