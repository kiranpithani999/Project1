# ---------------- VPC ----------------
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "eks-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

data "aws_availability_zones" "az" {}

# ---------------- Public Subnets ----------------
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "public-1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = { Name = "public-2" }
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# ---------------- IAM ROLES ----------------
resource "aws_iam_role" "cluster_role" {
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

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

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

resource "aws_iam_role_policy_attachment" "node1" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node2" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node3" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ---------------- SECURITY GROUP ----------------
resource "aws_security_group" "eks_sg" {
  name   = "eks-sg"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- EKS CLUSTER ----------------
resource "aws_eks_cluster" "eks" {
  name     = "demo-eks"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids              = [aws_subnet.public1.id, aws_subnet.public2.id]
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_sg.id]
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# ---------------- UBUNTU AMI ----------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ---------------- LAUNCH TEMPLATE ----------------
resource "aws_launch_template" "lt" {
  name_prefix   = "eks-ubuntu"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

# ---------------- NODE GROUP ----------------
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "ubuntu-workers"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.public1.id, aws_subnet.public2.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node1,
    aws_iam_role_policy_attachment.node2,
    aws_iam_role_policy_attachment.node3
  ]
}