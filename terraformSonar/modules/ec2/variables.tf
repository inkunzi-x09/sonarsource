variable "projectName" {
  type = string
}

variable "ami" {
  type = string
  default = "ami-067d1e60475437da2"
}

variable "instanceType" {
  type = string
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

variable "albSG" {
  type = string
}