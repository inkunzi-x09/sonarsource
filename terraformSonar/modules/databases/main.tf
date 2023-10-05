resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${var.projectName}-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.projectName}-subnet-group"
  }
}

resource "aws_db_instance" "rdsDB" {
  count = length(var.availabilityZones)
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  identifier = "db-instances-${count.index + 1}"
  username = "dbuser"
  password = "dbpassword"
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
  availability_zone = element(var.availabilityZones, count.index)
  skip_final_snapshot = true
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rdsSubnetSg.id]
  
  tags = {
    Name = "${var.projectName}-rds-instance-AZ${count.index + 1}"
  }
}

resource "aws_security_group" "rdsSubnetSg" {
  name = "${var.projectName}-rds-instance-sg"
  vpc_id = var.vpc_id

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