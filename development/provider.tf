provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.eks_endpoint
  cluster_ca_certificate = module.eks.eks_cluster_ca_cert
  token                  = module.eks.eks_cluster_token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_endpoint
    cluster_ca_certificate = module.eks.eks_cluster_ca_cert
    token                  = module.eks.eks_cluster_token
    load_config_file       = false
  }
}

