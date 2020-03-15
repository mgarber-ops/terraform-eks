output "efs_id" {
  value = aws_efs_file_system.efs_fs.id
}

output "efs_dns" {
  value = aws_efs_file_system.efs_fs.dns_name
}

output "efs_sg" {
  value = aws_security_group.efs_sg.id
}
