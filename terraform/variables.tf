variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "slack-notified-eks-cluster"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "sample-app-repo"
}

variable "ec2_key_name" {
  description = "AWS Key Pair name to SSH into the Jenkins Agent node"
  type        = string
  default     = "cicd_keypair"
}

variable "ec2_instance_type" {
  description = "Instance type for the standalone EC2"
  type        = string
  default     = "t3.micro"
}
