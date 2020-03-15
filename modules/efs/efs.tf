resource "aws_efs_file_system" "efs_fs" {
  creation_token = var.efs_name
  tags = {
    Name = var.efs_name
  }
}

resource "aws_efs_mount_target" "efs_mt" {
  count           = length(var.subnets)
  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = element(var.subnets, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}
