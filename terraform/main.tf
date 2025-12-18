data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.additional_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

module "vpc" {
  source                = "./modules/vpc"
  name_prefix           = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  tags                  = local.common_tags
}

module "ecr" {
  source               = "./modules/ecr"
  name_prefix          = local.name_prefix
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  lifecycle_keep_count = var.ecr_lifecycle_keep_count
  tags                 = local.common_tags
}

module "eks" {
  source              = "./modules/eks"
  name_prefix         = local.name_prefix
  cluster_version     = var.eks_cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  node_disk_size      = var.eks_node_disk_size
  tags                = local.common_tags
  depends_on          = [module.vpc]
}

module "rds" {
  source                  = "./modules/rds"
  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  database_subnet_ids     = module.vpc.database_subnet_ids
  eks_security_group_id   = module.eks.node_security_group_id
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  engine_version          = var.rds_engine_version
  database_name           = var.rds_database_name
  username                = var.rds_username
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection
  tags                    = local.common_tags
  depends_on              = [module.vpc, module.eks]
}

module "secrets" {
  source                      = "./modules/secrets"
  name_prefix                 = local.name_prefix
  database_endpoint           = module.rds.endpoint
  database_port               = module.rds.port
  database_name               = var.rds_database_name
  database_username           = var.rds_username
  database_password           = module.rds.password
  slack_webhook_url           = var.slack_webhook_url
  eks_cluster_oidc_issuer_url = module.eks.oidc_issuer_url
  eks_node_role_arn           = module.eks.node_role_arn
  tags                        = local.common_tags
  depends_on                  = [module.rds, module.eks]
}

module "alb_controller" {
  source                  = "./modules/alb-controller"
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.oidc_issuer_url
  vpc_id                  = module.vpc.vpc_id
  tags                    = local.common_tags
  depends_on              = [module.eks]
}

module "external_secrets" {
  source                  = "./modules/external-secrets"
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.oidc_issuer_url
  namespace               = "external-secrets"
  tags                    = local.common_tags
  depends_on              = [module.eks]
}
