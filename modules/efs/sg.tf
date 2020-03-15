resource "aws_security_group" "efs_sg" {

  name        = "efs-whitelist"
  description = "Allow EFS Traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_efs_ingress" {
  count             = length(var.subnet_cidrs)
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = [element(var.subnet_cidrs, count.index)]
  security_group_id = aws_security_group.efs_sg.id
}

resource "aws_security_group_rule" "allow_efs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_sg.id
}

