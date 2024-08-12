# print the ssh command to connect to the LAMP server
output "ssh_lamp_server_command" {
  value     = join ("", ["ssh -i ${local_file.ssh_key.filename} ec2-user@", aws_instance.lamp_server.public_dns])
}
# print the url of the LAMP server
output "lamp_server_url" {
  value     = join ("", ["http://", aws_instance.lamp_server.public_ip, ":", "80"])
}