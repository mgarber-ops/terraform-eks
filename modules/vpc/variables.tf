variable "vpc_cidr" {
}

variable "pub_subnets" {
  type = list(string)
}

variable "priv_subnets" {
  type = list(string)
}

variable "cluster_name" {
}

