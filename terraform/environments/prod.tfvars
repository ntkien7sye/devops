# Prod environment
project_name = "nestjs-backend"
environment  = "prod"
aws_region   = "us-east-1"

vpc_cidr              = "10.0.0.0/16"
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
enable_nat_gateway    = true
single_nat_gateway    = false

eks_cluster_version     = "1.29"
eks_node_instance_types = ["t3.large"]
eks_node_desired_size   = 3
eks_node_min_size       = 3
eks_node_max_size       = 10
eks_node_disk_size      = 100

rds_instance_class           = "db.t3.medium"
rds_allocated_storage        = 100
rds_max_allocated_storage    = 500
rds_engine_version           = "15.4"
rds_database_name            = "nestjs_prod"
rds_multi_az                 = true
rds_backup_retention_period  = 30
rds_deletion_protection      = true

ecr_image_tag_mutability = "IMMUTABLE"
ecr_scan_on_push         = true
ecr_lifecycle_keep_count = 50

app_port = 5000

slack_webhook_url = ""

additional_tags = {
  Team       = "DevOps"
  CostCenter = "Engineering"
}
