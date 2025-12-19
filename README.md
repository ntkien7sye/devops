# DevOps NestJS Project

## Quick Start

### Local Development
```bash
# Start all services
docker compose up -d

# Check health
curl http://localhost:5000/api/v1/health

# View logs
docker compose logs -f backend
```

### Environment Variables
Required environment variables are set in `docker-compose.yml`.

### Branches
- `devlocal` - Local K8s lab testing
- `production` - AWS EKS deployment

### AWS Deployment
1. Configure AWS CLI: `aws configure`
2. Run Terraform:
   ```bash
   cd terraform
   terraform init
   terraform apply -var-file=environments/dev.tfvars
   ```
3. Push to `production` branch to trigger CI/CD

### GitHub Secrets Required
- `AWS_ROLE_ARN` - IAM Role ARN for OIDC
- `SLACK_WEBHOOK_URL` - Slack notifications (optional)
