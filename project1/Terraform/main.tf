locals {
  common_tags = {
    Project = var.project_name
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  public_subnet_azs    = var.public_subnet_azs
  private_subnet_cidrs = var.private_subnet_cidrs
  private_subnet_azs   = var.private_subnet_azs
  common_tags          = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
}