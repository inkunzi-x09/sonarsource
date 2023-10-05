resource "aws_instance" "ec2PrivSub" {
  count = length(var.privSubnetIps)
  ami = var.ami
  instance_type = var.instanceType
  subnet_id = element(var.privSubnetIps, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  vpc_security_group_ids = [aws_security_group.sonarInstanceSg.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get upgrade -y
    EOF

  tags = {
    Name = "${var.projectName}-ec2-instance-AZ${count.index + 1}"
  }
}

resource "aws_security_group" "sonarInstanceSg" {
  name = "${var.projectName}-ec2-instance-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [cidrsubnet(var.vpcCidrBlock, 8, 1), cidrsubnet(var.vpcCidrBlock, 8, 2), cidrsubnet(var.vpcCidrBlock, 8, 3)]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [cidrsubnet(var.vpcCidrBlock, 8, 4), cidrsubnet(var.vpcCidrBlock, 8, 5), cidrsubnet(var.vpcCidrBlock, 8, 6)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}