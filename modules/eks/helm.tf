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

resource "helm_release" "alb_ingress_cntrllr" {
  count = var.enable_alb ? 1 : 0
  depends_on = [aws_eks_cluster.eks_cluster,
  aws_eks_node_group.eks_worker_group]
  name       = "aws-alb-ingress-controller"
  chart      = "aws-alb-ingress-controller"
  repository = "http://storage.googleapis.com/kubernetes-charts-incubator"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "autoDiscoverAwsRegion"
    value = true
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = true
  }
}



resource "helm_release" "nginx_ingress_cntrllr" {
  count = var.enable_nginx ? 1 : 0
  depends_on = [aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_worker_group,
  helm_release.alb_ingress_cntrllr]
  name       = "nginx-ingress-controller"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "kube-system"

  set_string {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set_string {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.publicService.enabled"
    value = "true"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set_string {
    name  = "controller.config.server-tokens"
    value = "false"
  }
  set_string {
    name  = "controller.config.use-proxy-protocol"
    value = "false"
  }
  set_string {
    name  = "controller.config.compute-full-forwarded-for"
    value = "true"
  }
  set_string {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }
  set {
    name  = "controller.autoscaling.maxReplicas"
    value = 3
  }
  set {
    name  = "controller.autoscaling.minReplicas"
    value = 3
  }
  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }
}
