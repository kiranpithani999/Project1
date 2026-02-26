# =====================================
# VPC OUTPUTS
# =====================================

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# =====================================
# NAT
# =====================================

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "elastic_ip" {
  description = "Elastic IP for NAT"
  value       = module.vpc.elastic_ip
}

# =====================================
# EKS
# =====================================

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API Server Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = module.eks.cluster_arn
}

output "node_group_name" {
  description = "EKS Node Group Name"
  value       = module.eks.node_group_name
}