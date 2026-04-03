module "eks" {
  source = "./modules/eks"

  name               = var.cluster_name
  kubernetes_version = "1.30"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  endpoint_public_access = true

  # Enable Cluster Access Management (API-based)
  authentication_mode                         = "API_AND_CONFIG_MAP"
  # Re-enable to match existing resource for import
  enable_cluster_creator_admin_permissions     = true

  eks_managed_node_groups = {
    generic_node_group = {
      instance_types = ["t3.small"] # 2 vCPU, 2GB RAM (Stable)
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 1
      max_size       = 1
      desired_size   = 1 # Exactly 2 vCPU used across the whole account
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
