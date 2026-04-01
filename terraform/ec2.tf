# Standing up an EC2 instance as a standalone node is temporarily disabled
# to stay within the strict 1 vCPU limit for the entire account.
# This ensures the EKS cluster has the single vCPU it needs to provision.

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]
# 
#   filter {
#     name   = "name"
#     values = [""]
#   }
# }
# 
# resource "aws_security_group" "ec2_sg" {
#   name        = "standalone-ec2-sg"
#   description = "Security group for standalone EC2 instance"
#   vpc_id      = module.vpc.vpc_id
# 
#   ingress {
#     description = "Allow SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# 
# resource "aws_instance" "standalone_ec2" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = var.ec2_instance_type
#   key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null
#   subnet_id              = module.vpc.public_subnets[0]
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]
# 
#   # Optional: Automatically assign a public IP.
#   associate_public_ip_address = true
# 
#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               # Install dependencies (unzip is required for AWS CLI)
#               sudo yum install -y git unzip yum-utils
#               # Install Java (required for Jenkins Agent)
#               sudo amazon-linux-extras install java-openjdk11 -y
#               # Install Docker
#               sudo amazon-linux-extras install docker -y
#               sudo systemctl enable docker
#               sudo systemctl start docker
#               sudo usermod -a -G docker ec2-user
#               # Install AWS CLI v2
#               curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#               unzip awscliv2.zip
#               sudo ./aws/install
#               # Install Terraform
#               sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
#               sudo yum -y install terraform
#               # Install kubectl
#               curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#               chmod +x ./kubectl
#               sudo mv ./kubectl /usr/local/bin
#               EOF
# 
#   tags = {
#     Name = "Jenkins-Agent-EC2"
#   }
# }
