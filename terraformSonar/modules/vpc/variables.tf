variable "projectName" {
  default = "Sonar"
}

variable "vpcCidrBlock" {
  default = "10.0.0.0/16"
}

variable "availabilityZones" {
  type = list(string)
  description = "Availability zones"
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}

variable "privSubnetsIP" {
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}