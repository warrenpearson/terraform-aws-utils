variable "public_key_path" {
  default = "~/.ssh/app-key.pub"
}

variable "aws_region" {
  default = "eu-west-1c"
}

variable "key_name" {
  default = "app-key"
}

variable "aws_ami" {
  default = "ami-identifier"
}

variable "vpc" {
  default = "vpc-identifier"
}

variable "subnet" {
  default = "subnet-identifier"
}

variable "subnet-2" {
  default = "subnet-identifier"
}

variable "nexus-client-sg" {
  default = "sg-for_nexus"
}

variable "internal-network" {
  default = "0.0.0.0/32"
}
