output "bastion_host_public_ip" {
  value = aws_eip.bastion_host_eip.public_ip
}
