output "eks_control_plane_role" {
  value = aws_iam_role.eks_control_plane_iam_role.arn
}

output "eks_worker_node_role" {
  value = aws_iam_role.eks_worker_node_iam_role.arn
}

output "eks_cluster_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy_attachment.*.id
}

output "eks_worker_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_worker_node_policy_attachment.*.id
}
