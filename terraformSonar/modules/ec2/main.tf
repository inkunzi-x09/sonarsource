resource "aws_instance" "ec2PrivSub" {
  count = length(var.subnet_ids)
  ami = "ami-067d1e60475437da2"
  instance_type = "t2.micro"
  subnet_id = element(var.subnet_ids, count.index)
}