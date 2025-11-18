provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  public_cidr_blocks  = var.public_cidr_blocks 
  private_cidr_blocks = var.private_cidr_blocks
  default_route      = var.default_route
}


module "roles" {
  source = "./modules/roles"
}

module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block  
  private_subnets  = module.vpc.private_subnet_ids 
  cluster_role_arn = module.roles.cluster_role_arn
  node_role_arn    = module.roles.node_role_arn
  aws_region       = var.aws_region
}


module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}


module "endpoints" {
  source          = "./modules/endpoints"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  project_name    = var.project_name
  aws_region      = var.aws_region
  vpc_cidr_block  = module.vpc.vpc_cidr_block
}

