# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "lamp_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "lamp_key" {
  key_name   = var.key_pair_name 
  public_key = tls_private_key.lamp_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${var.key_pair_name}.pem"
  content  = tls_private_key.lamp_key.private_key_pem
  file_permission = "400"
}