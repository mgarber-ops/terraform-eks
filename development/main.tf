module "vpc" {
  source       = "../modules/vpc"
  vpc_cidr     = var.vpc_cidr
  pub_subnets  = var.pub_subnets
  priv_subnets = var.priv_subnets
  cluster_name = var.cluster_name
}

module "iam" {
  source            = "../modules/iam"
  worker_node_arns  = var.worker_node_arns
  eks_control_arns  = var.eks_control_arns
  enable_alb        = var.enable_alb
  enable_exdns      = var.enable_exdns
  cluster_name      = var.cluster_name
  enable_autoscaler = var.enable_autoscaler
}

module "eks" {
  source                      = "../modules/eks"
  subnet_ids                  = module.vpc.private_subnets
  eks_sg                      = module.vpc.eks_sg
  eks_cluster_role_arn        = module.iam.eks_control_plane_role
  eks_worker_role_arn         = module.iam.eks_worker_node_role
  enable_alb                  = var.enable_alb
  enable_exdns                = var.enable_exdns
  enable_nginx                = var.enable_nginx
  cluster_name                = var.cluster_name
  node_group_names            = var.node_group_names
  eks_worker_role_attachment  = module.iam.eks_worker_policy_attachment
  eks_cluster_role_attachment = module.iam.eks_cluster_policy_attachment
  efs_fs                      = module.efs.efs_id
  asg_min                     = var.asg_min
  asg_max                     = var.asg_max
  eks_node_version            = var.eks_node_version
  asg_desired                 = var.asg_desired
  eks_cluster_version         = var.eks_cluster_version
  instance_type               = var.instance_type
}

module "efs" {
  source       = "../modules/efs"
  efs_name     = var.efs_name
  vpc_id       = module.vpc.vpc
  subnets      = module.vpc.private_subnets
  subnet_cidrs = var.priv_subnets
}
