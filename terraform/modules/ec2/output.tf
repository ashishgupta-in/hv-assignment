output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "static_web_ip" {
  value = aws_instance.static_web_server.public_ip
}

output "static_web_dns" {
  value = aws_instance.static_web_server.public_dns
}
