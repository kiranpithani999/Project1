provider "aws" {
  region = "ap-south-1"
}

# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "my_nat_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_nat_vpc"
  }
}

# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_nat_vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

# ----------------------------
# Public Subnets
# ----------------------------
resource "aws_subnet" "sub_public1" {
  vpc_id                  = aws_vpc.my_nat_vpc.id
  cidr_block              = "10.0.101.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub_public1"
  }
}

resource "aws_subnet" "sub_public2" {
  vpc_id                  = aws_vpc.my_nat_vpc.id
  cidr_block              = "10.0.102.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub_public2"
  }
}

# ----------------------------
# Private Subnets
# ----------------------------
resource "aws_subnet" "sub_private1" {
  vpc_id            = aws_vpc.my_nat_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "sub_private1"
  }
}

resource "aws_subnet" "sub_private2" {
  vpc_id            = aws_vpc.my_nat_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "sub_private2"
  }
}

# ----------------------------
# Elastic IP for NAT
# ----------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat_eip"
  }
}

# ----------------------------
# NAT Gateway
# ----------------------------
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sub_public1.id

  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "nat_gateway"
  }
}

# ----------------------------
# Public Route Table
# ----------------------------
resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.my_nat_vpc.id

  tags = {
    Name = "route_public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.route_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.sub_public1.id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.sub_public2.id
  route_table_id = aws_route_table.route_public.id
}

# ----------------------------
# Private Route Table
# ----------------------------
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.my_nat_vpc.id

  tags = {
    Name = "route_private"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.route_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_assoc1" {
  subnet_id      = aws_subnet.sub_private1.id
  route_table_id = aws_route_table.route_private.id
}

resource "aws_route_table_association" "private_assoc2" {
  subnet_id      = aws_subnet.sub_private2.id
  route_table_id = aws_route_table.route_private.id
}