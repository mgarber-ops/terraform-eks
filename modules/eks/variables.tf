variable "subnet_ids" {
  type = list(string)
}

variable "eks_sg" {
}

variable "eks_cluster_role_arn" {
}

variable "eks_worker_role_arn" {
}

variable "enable_alb" {
}

variable "enable_nginx" {

}

variable "enable_exdns" {
}

variable "cluster_name" {
}

variable "node_group_names" {
}

variable "eks_cluster_role_attachment" {
}

variable "eks_worker_role_attachment" {
}

variable "efs_fs" {
}

variable "asg_desired" {
}

variable "asg_max" {
}

variable "asg_min" {
}

variable "eks_node_version" {
}

variable "eks_cluster_version" {

}

variable "instance_type" {

}

variable "public_access_cidrs" {
}
