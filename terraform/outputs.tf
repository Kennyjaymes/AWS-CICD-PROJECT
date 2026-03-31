output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "ECR Repo URL"
  value       = aws_ecr_repository.app_repo.repository_url
}

# output "standalone_ec2_public_dns" {
#   description = "Public DNS of the standalone EC2 instance"
#   value       = aws_instance.standalone_ec2.public_dns
# }
# 
# output "standalone_ec2_public_ip" {
#   description = "Public IP of the standalone EC2 instance"
#   value       = aws_instance.standalone_ec2.public_ip
# }
