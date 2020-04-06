
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_ami" {
  default = "ami-0cb790308f7591fa6"
}

variable "availability_zone" {
  default = "us-east-2a"
}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
