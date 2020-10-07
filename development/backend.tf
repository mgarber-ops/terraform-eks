terraform {
  backend "s3" {
    bucket = "mgarber-ops-state-bucket"
    key    = "poc/eks.tfstate"
    region = "us-east-1"
  }
}
