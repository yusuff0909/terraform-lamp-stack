variable aws_region {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}
variable aws_instance_type {
  description = "This is aws ec2 type "
  default = "t2.micro"
  type        = string
}
variable key_pair_name {
  description = "This is name of the key pair"
  default     = "lamp_key_pair"
  type        = string
}
