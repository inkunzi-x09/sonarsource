variable "projectName" {
  type = string
}

variable "pub_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "vpcCidrBlock" {
  type = string
}

variable "nat_gateway_ip" {
  type = list(string)
}

variable "uniqueTagSuffix" {
  type = string
}