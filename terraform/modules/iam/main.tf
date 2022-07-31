# Instance IAM Role 
resource "aws_iam_role" "role" {
  name = "${var.project_name}-health-check-service-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# SNS full access policy attachment
resource "aws_iam_role_policy_attachment" "sns_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  depends_on = [aws_iam_role.role]
}

# IAM Instance Profile 
resource "aws_iam_instance_profile" "instance_role" {
  name       = "${var.project_name}-health-check-service"
  role       = aws_iam_role.role.name
  depends_on = [aws_iam_role.role, aws_iam_role_policy_attachment.sns_policy]
}
