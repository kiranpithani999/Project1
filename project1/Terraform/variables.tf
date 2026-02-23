# ----------------------------
# AWS REGION
# ----------------------------
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

# ----------------------------
# PROJECT
# ----------------------------
variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "AWS_infra"
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

# ----------------------------
# VPC
# ----------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ----------------------------
# PUBLIC SUBNETS (Multi-AZ)
# ----------------------------
variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_azs" {
  description = "List of AZs for public subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# ----------------------------
# PRIVATE SUBNETS (Multi-AZ)
# ----------------------------
variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_azs" {
  description = "List of AZs for private subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# ----------------------------
# NAT
# ----------------------------
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

# ----------------------------
# EKS CLUSTER
# ----------------------------
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "kiran_eks_cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "endpoint_private_access" {
  description = "Enable private endpoint access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public endpoint access"
  type        = bool
  default     = true
}

# ----------------------------
# EKS NODE GROUP
# ----------------------------
variable "node_group_name" {
  description = "Node group name"
  type        = string
  default     = "eks-node-group"
}

variable "instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
  default     = ["t2.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}