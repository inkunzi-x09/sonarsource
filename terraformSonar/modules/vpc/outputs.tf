output "priv_subnet_ids" {
  value = aws_subnet.privSubnets[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.dbSubnets[*].id
}

output "pub_subnet_ids" {
  value = aws_subnet.pubSubnets[*].id
}

output "vpc_id" {
  value = aws_vpc.sonarVPC.id
}