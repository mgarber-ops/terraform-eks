data "aws_region" "current" {}

resource "helm_release" "efs_provisioner" {
  depends_on = [aws_eks_cluster.eks_cluster,
  aws_eks_node_group.eks_worker_group]
  name       = "efs-provisioner"
  chart      = "efs-provisioner"
  repository = "https://kubernetes-charts.storage.googleapis.com"

  set {
    name  = "efsProvisioner.efsFileSystemId"
    value = var.efs_fs
  }

  set {
    name  = "efsProvisioner.awsRegion"
    value = data.aws_region.current.name
  }
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [aws_eks_cluster.eks_cluster,
  aws_eks_node_group.eks_worker_group]
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes-charts.storage.googleapis.com"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.pspEnabled"
    value = "true"
  }
}
