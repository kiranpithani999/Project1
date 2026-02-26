output "vpc_id" {
  value = aws_vpc.my_nat_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "elastic_ip" {
  value = aws_eip.nat_eip.public_ip
}