resource "aws_vpc" "sonarVPC" {
  cidr_block = var.vpcCidrBlock
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.projectName}-vpc"
  }
}

resource "aws_subnet" "pubSubnets" {
  count = length(var.pubSubnetIps)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(var.pubSubnetIps, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.projectName}-public-subnet-AZ${count.index + 1}"
  }
}

resource "aws_subnet" "privSubnets" {
  count = length(var.availabilityZones)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(var.privSubnetIps, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  tags = {
    Name = "${var.projectName}-private-subnet-AZ${count.index + 1}"
  }
}

resource "aws_subnet" "dbSubnets" {
  count = length(var.availabilityZones)
  vpc_id = aws_vpc.sonarVPC.id
  cidr_block = element(var.dbSubnetIps, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  tags = {
    Name = "${var.projectName}-db-subnet-AZ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "sonarIgw" {
  vpc_id = aws_vpc.sonarVPC.id
  tags = {
    Name = "${var.projectName}-igw"
  }
}

resource "aws_eip" "nat_gateway" {
  count = length(aws_subnet.pubSubnets)
  depends_on = [ aws_internet_gateway.sonarIgw ]
}

resource "aws_nat_gateway" "sonarNatGW" {
  count = length(aws_subnet.pubSubnets)
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id = aws_subnet.pubSubnets[count.index].id
  tags = {
    "Name" = "${var.projectName}-nat-gw-${count.index + 1}"
  }
}

resource "aws_route_table" "rtForPubSub" {
  vpc_id = aws_vpc.sonarVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sonarIgw.id
  }
  tags = {
    Name = "${var.projectName}-rt-for-public-subnets"
  }
}

resource "aws_route_table_association" "pubSubnetAsso" {
    count = length(var.pubSubnetIps)
    subnet_id = element(aws_subnet.pubSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForPubSub.id
}

resource "aws_route_table" "rtForPrivSub" {
  count = length(aws_subnet.privSubnets)
  vpc_id = aws_vpc.sonarVPC.id
  route {
    cidr_block ="0.0.0.0/0"
    gateway_id = aws_nat_gateway.sonarNatGW[count.index].id
  }
  tags = {
    Name = "${var.projectName}-rt-for-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "privSubnetAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.privSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForPrivSub[count.index].id
}

resource "aws_route_table" "rtForDbSub" {
  count = length(aws_subnet.dbSubnets)
  vpc_id = aws_vpc.sonarVPC.id
  tags = {
    Name = "${var.projectName}-rt-for-db-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "dbSubnetAsso" {
    count = length(var.availabilityZones)
    subnet_id = element(aws_subnet.dbSubnets[*].id, count.index)
    route_table_id = aws_route_table.rtForDbSub[count.index].id
}



resource "aws_network_acl" "aclPubSub" {
  vpc_id = aws_vpc.sonarVPC.id
  subnet_ids = aws_subnet.pubSubnets[*].id
  ingress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = var.vpcCidrBlock
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "6"
    rule_no = 105
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  ingress {
    protocol = "6"
    rule_no = 110
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  depends_on = [ aws_subnet.pubSubnets ]
  tags = {
    Name = "${var.projectName}-nacl-public-subnets"
  }
}

resource "aws_network_acl" "aclPrivSub" {
  vpc_id = aws_vpc.sonarVPC.id
  subnet_ids = aws_subnet.privSubnets[*].id
  ingress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = var.vpcCidrBlock
    from_port = 0
    to_port = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "${var.projectName}-nacl-private-subnets"
  }
}

resource "aws_network_acl" "aclDbSub" {
  vpc_id = aws_vpc.sonarVPC.id
  subnet_ids = aws_subnet.dbSubnets[*].id
  ingress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = var.vpcCidrBlock
    from_port = 0
    to_port = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "${var.projectName}-nacl-db-subnets"
  }
}