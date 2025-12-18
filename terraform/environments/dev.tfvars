
# Development Environment Configuration
project_name = "nestjs-backend"
environment  = "dev"
aws_region   = "us-east-1"

# Networking
vpc_cidr              = "10.0.0.0/16"
availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
enable_nat_gateway    = true
single_nat_gateway    = true # Cost saving for dev

# EKS Configuration
eks_cluster_version     = "1.29"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 2
eks_node_max_size       = 4
eks_node_disk_size      = 50

# RDS Configuration
rds_instance_class           = "db.t3.micro"
rds_allocated_storage        = 20
rds_max_allocated_storage    = 100
rds_engine_version           = "15.4"
rds_database_name            = "nestjs_dev"
rds_multi_az                 = false
rds_backup_retention_period  = 7
rds_deletion_protection      = false

# ECR Configuration
ecr_image_tag_mutability = "MUTABLE"
ecr_scan_on_push         = true
ecr_lifecycle_keep_count = 30

# Application
app_port = 5000

# Slack Webhook (placeholder - replace with actual webhook)
slack_webhook_url = "https://SLACK_WEBHOOK_REMOVED/services/XXXXX/XXXXX/XXXXX"

# Additional Tags
additional_tags = {
  Team        = "DevOps"
  CostCenter  = "Engineering"
}
