variable "public_key_path" {
  default = "~/.ssh/pub_key.pub"
}

variable "aws_region" {
  default = "eu-west-1c"
}

variable "key_name" {
  default = "pub_key"
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

variable "route53_zone_id" {
 default = "zone-identifier"
}
