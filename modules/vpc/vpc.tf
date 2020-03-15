locals {
  common_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

data "aws_availability_zones" "available_azs" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  lifecycle {
    ignore_changes = [
      tags.name
    ]
  }
  tags = merge(
    local.common_tags,
    {
    },
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      tags.name
    ]
  }
}

resource "aws_subnet" "pub_subnets" {
  count                   = length(var.pub_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.pub_subnets, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available_azs.names, count.index)
  depends_on              = [aws_internet_gateway.igw]

  lifecycle {
    ignore_changes = [
      tags.name
    ]
  }

  tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/elb" = "1"
    },
  )
}

resource "aws_subnet" "priv_subnets" {
  count             = length(var.priv_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.priv_subnets, count.index)
  availability_zone = element(data.aws_availability_zones.available_azs.names, count.index)

  lifecycle {
    ignore_changes = [
      tags.name
    ]
  }

  tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/internal-elb" = "1"
    },
  )
}

resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "rt_priv" {
  count  = length(var.priv_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }
}

resource "aws_eip" "ngw_eip" {
  count = length(var.priv_subnets)
  vpc   = true
}

resource "aws_nat_gateway" "ngw" {
  count         = length(aws_eip.ngw_eip)
  allocation_id = aws_eip.ngw_eip[count.index].id
  subnet_id     = aws_subnet.pub_subnets[count.index].id
  depends_on    = [aws_internet_gateway.igw, aws_eip.ngw_eip]
}

resource "aws_route_table_association" "rt_priv_association" {
  count          = length(aws_subnet.priv_subnets)
  subnet_id      = aws_subnet.priv_subnets[count.index].id
  route_table_id = aws_route_table.rt_priv[count.index].id
}

resource "aws_route_table_association" "rt_pub_assocation" {
  count          = length(aws_subnet.pub_subnets)
  subnet_id      = aws_subnet.pub_subnets[count.index].id
  route_table_id = aws_route_table.rt_pub.id
}


resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound Traffic"
  security_group_id = aws_security_group.eks_sg.id
}

resource "aws_security_group" "eks_sg" {
  name   = "EKS Control Plane Security Group - Allow Workers"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_inter_eks_traffic" {
  count     = length(var.priv_subnets)
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = [element(var.priv_subnets, count.index)]
  description       = "Allow Inbound Traffic from Public Subnets"
  security_group_id = aws_security_group.eks_sg.id
}
