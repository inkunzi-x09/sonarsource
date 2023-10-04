resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "MyDB Subnet Group"
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
  tags = {
    Name = "RDS instance AZ${count.index + 1}"
  }
  skip_final_snapshot = true
}