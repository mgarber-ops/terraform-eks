variable "worker_node_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "eks_control_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
}

variable "enable_alb" {
}

variable "enable_exdns" {
}

variable "cluster_name" {
}

variable "enable_autoscaler" {
}
