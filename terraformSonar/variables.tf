variable "AWS_REGION" {
  default = "us-east-1"
}

variable "projectName" {
  default = "Sonar"
}

variable "vpcCidrBlock" {
  default = "10.0.0.0/16"
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