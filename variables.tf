
variable "aws_region" {
  description = "aws regions"
  default = "us-east-1"
}

variable "instance_ami" {
  description = "region specific aws ami instance id"
  default = "ami-0323c3dd2da7fb37d"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR range with masking"
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Available AZs as per regions"
  default = ""
}
variable "public_key_path" {
  description = "private key path for EC2 instance"
  default = ""
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
