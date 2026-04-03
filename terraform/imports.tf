import {
  to = aws_ecr_repository.app_repo
  id = var.ecr_repo_name
}

import {
  to = module.eks.module.kms.aws_kms_alias.this["cluster"]
  id = "alias/eks/${var.cluster_name}"
}

import {
  to = module.eks.aws_cloudwatch_log_group.this[0]
  id = "/aws/eks/${var.cluster_name}/cluster"
}

# import {
#   to = module.eks.aws_eks_access_entry.this["cluster_creator"]
#   id = "${var.cluster_name}:arn:aws:iam::667736132185:user/jenkins-user"
# }
