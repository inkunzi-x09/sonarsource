variable "projectName" {
  type = string
}

variable "vpcCidrBlock" {
  type = string
}

variable "availabilityZones" {
  type = list(string)
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