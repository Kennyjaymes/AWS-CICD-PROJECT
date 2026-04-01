module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.16"

  cluster_name    = var.cluster_name
  cluster_version = "1.30" # Changed from 1.30 to allow 1.28 -> 1.29 upgrade

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_public_access = true

  self_managed_node_groups = {
    generic_node_group = {
      instance_type = "t2.small" # 1 vCPU, 2GB RAM (Stable)
      min_size      = 1
      max_size      = 1
      desired_size  = 1 # Exactly 1 vCPU used across the whole account
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

# The aws_eks_cluster_auth data source allows grabbing auth info for kubernetes provider
# We remove the data source 'aws_eks_cluster' and use the module outputs directly 
# to avoid circular dependencies (Cycles).
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
