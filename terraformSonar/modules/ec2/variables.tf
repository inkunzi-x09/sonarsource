variable "projectName" {
  type = string
}

variable "ami" {
  type = string
}

variable "instanceType" {
  type = string
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