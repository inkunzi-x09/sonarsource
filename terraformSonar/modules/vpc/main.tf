resource "aws_vpc" "sonarVPC" {
  cidr_block = var.vpcCidrBlock
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.projectName}-vpc"
  }
}

resource "aws_subnet" "pubSubnets" {
  count = length(var.availabilityZones)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone = element(var.availabilityZones, count.index)
  tags = {
    Name = "Public subnet AZ${count.index + 1}"
  }
}

resource "aws_subnet" "privSubnets" {
  count = length(var.availabilityZones)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(var.privSubnetsIP, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  tags = {
    Name = "Private subnet AZ${count.index + 1}"
  }
}

resource "aws_subnet" "dbSubnets" {
  count = length(var.availabilityZones)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"], count.index)
  availability_zone = element(var.availabilityZones, count.index)
  tags = {
    Name = "Database subnet AZ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "sonarIgw" {
  vpc_id = aws_vpc.sonarVPC.id
  tags = {
    Name = "Sonar IGW"
  }
}

resource "aws_route_table" "rtForSonarIgw" {
  vpc_id = aws_vpc.sonarVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sonarIgw.id
  }
  tags = {
    Name = "RTToIgw"
  }
}

resource "aws_route_table_association" "pubSubnetAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.pubSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForSonarIgw.id
}

resource "aws_route_table" "rtForPrivSub" {
  vpc_id = aws_vpc.sonarVPC.id
  
  tags = {
    Name = "RTPrivSub"
  }
}

resource "aws_route_table_association" "privSubnetAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.privSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForPrivSub.id
}

resource "aws_route_table" "rtForDBSub" {
  vpc_id = aws_vpc.sonarVPC.id
  
  tags = {
    Name = "RTDB"
  }
}

resource "aws_route_table_association" "dbSubnetAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.dbSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForDBSub.id
}

resource "aws_eip" "nat_gateway" {
  count = length(aws_subnet.pubSubnets)
}

resource "aws_nat_gateway" "sonarNatGW" {
  count = length(aws_subnet.pubSubnets)
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id = aws_subnet.pubSubnets[count.index].id
  tags = {
    "Name" = "sonar-natGW-${count.index + 1}"
  }
}

resource "aws_route_table" "rtForNatGW" {
  vpc_id = aws_vpc.sonarVPC.id
  
  tags = {
    Name = "RTNatGW"
  }
}

resource "aws_route_table_association" "natGWAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.pubSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForNatGW.id
}

output "subnet_ids" {
  value = aws_subnet.privSubnets[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.dbSubnets[*].id
}

output "pub_subnet_ids" {
  value = aws_subnet.pubSubnets[*].id
}