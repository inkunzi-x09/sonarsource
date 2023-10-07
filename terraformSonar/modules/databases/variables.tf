variable "projectName" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpcCidrBlock" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "availabilityZones" {
  type = list(string)
  description = "Availability zones"
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}