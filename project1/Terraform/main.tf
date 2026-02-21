# =========================
# VPC
# =========================
resource "aws_vpc" "my_nat_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_nat_vpc"
  }
}

# =========================
# Internet Gateway
# =========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_nat_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# =========================
# Public Subnet
# =========================
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_nat_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

# =========================
# Private Subnet
# =========================
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_nat_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private_subnet"
  }
}

# =========================
# Elastic IP (for NAT)
# =========================
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# =========================
# NAT Gateway
# =========================
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "my_nat_gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# =========================
# Public Route Table
# =========================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_nat_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# =========================
# Private Route Table (via NAT)
# =========================
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_nat_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# =========================
# IAM ROLE FOR EKS
# =========================
resource "aws_iam_role" "eks_cluster_role" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy1" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# =========================
# IAM ROLE FOR NODE GROUP
# =========================
resource "aws_iam_role" "node_role" {
  name = "eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_policy1" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_policy2" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "worker_policy3" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# =========================
# EKS CLUSTER (PUBLIC SUBNET ONLY)
# =========================
resource "aws_eks_cluster" "eks" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy1
  ]
}

# =========================
# NODE GROUP (PUBLIC)
# =========================
resource "aws_eks_node_group" "public_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "public-workers"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.public_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy1,
    aws_iam_role_policy_attachment.worker_policy2,
    aws_iam_role_policy_attachment.worker_policy3
  ]
}