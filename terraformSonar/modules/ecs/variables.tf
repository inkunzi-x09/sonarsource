variable "projectName" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpcCidrBlock" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}