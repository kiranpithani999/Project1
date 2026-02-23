# =====================================
# VPC OUTPUTS
# =====================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my_nat_vpc.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

# =====================================
# NAT
# =====================================

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat_gw.id
}

output "elastic_ip" {
  description = "Elastic IP for NAT"
  value       = aws_eip.nat_eip.public_ip
}

# =====================================
# EKS
# =====================================

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  description = "EKS API Server Endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "node_group_name" {
  description = "EKS Node Group Name"
  value       = aws_eks_node_group.node_group.node_group_name
}