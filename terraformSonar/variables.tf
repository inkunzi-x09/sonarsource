variable "AWS_REGION" {
  default = "us-east-1"
}

variable "vpcCidrBlock" {
  default = "10.0.0.0/16"
}

variable "availabilityZones" {
  type = list(string)
  description = "Availability zones"
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
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