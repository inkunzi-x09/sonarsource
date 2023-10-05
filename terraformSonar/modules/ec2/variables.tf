variable "projectName" {
  type = string
}

variable "ami" {
  type = string
  description = "Amazon Linux 2023 AMI 2023.2.20231002.0 x86_64 HVM kernel-6.1"
  default = "ami-067d1e60475437da2"
}

variable "instanceType" {
  type = string
  description = "Instance type for free tier"
  default = "t2.micro"
}

variable "vpcCidrBlock" {
  type = string
}

variable "pubSubnetIps" {
  type = list(string)
}

variable "privSubnetIps" {
  type = list(string)
}

variable "dbSubnetIps" {
  type = list(string)
}

variable "availabilityZones" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}