resource "aws_db_instance" "rdsDB" {
  count = length(var.subnet_ids)
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  identifier = "db-instances-${count.index + 1}"
  username = "dbuser"
  password = "dbpassword"
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
  tags = {
    Name = "RDS instance AZ${count.index + 1}"
  }
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "MyDB Subnet Group"
  }
}