variable "vpc_cidr" {
  default = "10.150.0.0/16"
}

variable "pub_subnets" {
  type    = list(string)
  default = ["10.150.1.0/24", "10.150.2.0/24", "10.150.3.0/24"]
}

variable "priv_subnets" {
  type    = list(string)
  default = ["10.150.10.0/24", "10.150.20.0/24", "10.150.30.0/24"]
}


variable "worker_node_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "eks_control_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
}

variable "asg_desired" {
  default = 3
}

variable "asg_min" {
  default = 3
}

variable "asg_max" {
  default = 3
}
variable "enable_alb" {
  default = false
}

variable "enable_exdns" {
  default = false
}

variable "enable_autoscaler" {
  default = true

}

variable "enable_nginx" {
 default = false
}

variable "cluster_name" {
  default = "eks-test-cluster-a"
}

variable "node_group_names" {
  type    = list(string)
  default = ["test-node-group-a"]
}

variable "efs_name" {
  default = "test-efs"
}

variable "eks_node_version" {
  default = ""
}

variable "eks_cluster_version" {
  default = "1.17"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "public_access_cidrs" {
  type = "list(string)"
  default = ["141.155.129.215/32", "104.154.63.253/32", "104.197.160.122/32", "18.213.176.41/32", "13.59.201.170/32", "104.155.130.126/32", "147.234.23.250/32", "34.233.31.180/32", "18.210.174.176/32", "104.154.99.188/32", "146.148.100.14/32"]}
