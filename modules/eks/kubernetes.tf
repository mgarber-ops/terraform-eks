resource "kubernetes_deployment" "external_dns" {
  depends_on = [
    kubernetes_service_account.exdns_service_account,
    kubernetes_cluster_role_binding.exdns_cluster_role_binding,
    kubernetes_cluster_role.exdns_cluster_role,
    aws_eks_node_group.eks_worker_group
  ]

  //Only deploy External DNS if both Enable ALB and Enable DNS = 1
  //Bool Style of If AND condition
  count = var.enable_exdns && var.enable_alb ? 1 : 0
  metadata {
    name = "external-dns"
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "app" = "external-dns"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "external-dns"
        }
      }
      spec {
        automount_service_account_token = "true"
        container {
          name  = "external-dns"
          image = "registry.opensource.zalan.do/teapot/external-dns:v0.5.9"
          args = [
            "--source=service",
            "--source=ingress",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
          ]
        }
        service_account_name = kubernetes_service_account.exdns_service_account[0].metadata[0].name
      }
    }
  }
}

resource "kubernetes_cluster_role" "exdns_cluster_role" {
  count = var.enable_exdns && var.enable_alb ? 1 : 0
  metadata {
    name = "external-dns"
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "exdns_cluster_role_binding" {
  count = var.enable_exdns && var.enable_alb ? 1 : 0
  metadata {
    name = "external-dns-viewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.exdns_service_account[0].metadata[0].name
    namespace = "default"
  }
}

resource "kubernetes_service_account" "exdns_service_account" {
  count                           = var.enable_exdns && var.enable_alb ? 1 : 0
  automount_service_account_token = "true"
  metadata {
    name      = "external-dns"
    namespace = "default"
  }
}

