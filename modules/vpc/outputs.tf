output "public_subnets" {
  value = aws_subnet.pub_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.priv_subnets.*.id
}

output "vpc" {
  value = aws_vpc.main.id
}

output "eks_sg" {
  value = aws_security_group.eks_sg.id
}

