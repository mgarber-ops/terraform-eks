output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_ca_cert" {
  value = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}

output "eks_cluster_token" {
  value = data.aws_eks_cluster_auth.example.token
}

output "eks_cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}
