locals {
  workstation-external-cidr = "${chomp(data.http.ip.body)}/32"
  common_tags = {
  Environment = "Development"
  Component   = "EKS"
  Owner       = "mgarber-ops"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  depends_on = [var.eks_cluster_role_attachment]
  name       = var.cluster_name
  role_arn   = var.eks_cluster_role_arn
  version    = var.eks_cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.eks_sg]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = [local.workstation-external-cidr]
  }
 tags = merge(map("Name", "eks-cluster-test"), local.common_tags)
}

data "http" "ip" {
url = "http://ipv4.icanhazip.com/"
}

resource "aws_eks_node_group" "eks_worker_group" {
  count = length(var.node_group_names)
  depends_on = [var.eks_worker_role_attachment,
    aws_eks_cluster.eks_cluster,
  aws_ebs_encryption_by_default.this]

  cluster_name    = aws_eks_cluster.eks_cluster.id
  node_group_name = element(var.node_group_names, count.index)
  node_role_arn   = var.eks_worker_role_arn
  subnet_ids = var.subnet_ids
  
 tags = merge(map("Name", "eks-node-group-${count.index}", "k8s.io/cluster-autoscaler/${var.cluster_name}", "owned", "k8s.io/cluster-autoscaler/enabled", "true" ), local.common_tags)
                   
  release_version = var.eks_node_version

  scaling_config {
    desired_size = var.asg_desired
    max_size     = var.asg_max
    min_size     = var.asg_min
  }

}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

