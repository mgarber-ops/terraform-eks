output "eks_endpoint" {
  value = module.eks.eks_endpoint
}

output "eks_cluster_ca_cert" {
  value = module.eks.eks_cluster_ca_cert
}

output "eks_cluster_token" {
  value = module.eks.eks_cluster_token
}

