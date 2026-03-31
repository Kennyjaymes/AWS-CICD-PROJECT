module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = var.cluster_name
  cluster_version = "1.30" # Updated for better AMI compatibility

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    generic_node_group = {
      instance_types = ["t2.micro"] # Changed from t3.medium to fit in 1 vCPU
      min_size       = 1
      max_size       = 2
      desired_size   = 1 # Reduced from 2 to stay within vCPU limits
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
