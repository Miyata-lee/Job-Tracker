#!/bin/bash
# File: scripts/deploy-frontend.sh
# JobTracker S3 + CloudFront Deployment Script

set -e

PROJECT_NAME="${PROJECT_NAME:-jobtracker}"
ENVIRONMENT="${ENVIRONMENT:-prod}"
AWS_REGION="${AWS_REGION:-us-east-1}"
FRONTEND_DIR="frontend-app/templates"
LOG_FILE="/tmp/jobtracker-frontend-deploy.log"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}" | tee -a $LOG_FILE
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}" | tee -a $LOG_FILE
}

error_exit() {
    log_error "$1"
    exit 1
}

log "=========================================="
log "JobTracker S3 + CloudFront Deployment"
log "=========================================="

log "Step 1: Checking AWS CLI"
if ! command -v aws &> /dev/null; then
    error_exit "AWS CLI not installed"
fi
log_success "AWS CLI found"

log "Step 2: Validating frontend directory"
if [ ! -d "$FRONTEND_DIR" ]; then
    error_exit "Frontend directory not found: $FRONTEND_DIR"
fi
log_success "Frontend directory found"

log "Step 3: Getting S3 bucket name"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="${PROJECT_NAME}-frontend-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"

if ! aws s3 ls "s3://${S3_BUCKET}" 2>/dev/null; then
    error_exit "S3 bucket not found: $S3_BUCKET"
fi
log_success "S3 bucket found: $S3_BUCKET"

log "Step 4: Uploading files to S3"
aws s3 sync "$FRONTEND_DIR" "s3://${S3_BUCKET}" \
    --region $AWS_REGION \
    --delete \
    --cache-control "max-age=3600"
log_success "Files uploaded to S3"

log "Step 5: Getting CloudFront distribution ID"
CLOUDFRONT_ID=$(aws cloudfront list-distributions \
    --query 'Distributions[0].Id' \
    --output text)

if [ -z "$CLOUDFRONT_ID" ]; then
    error_exit "CloudFront distribution not found"
fi
log_success "CloudFront distribution found: $CLOUDFRONT_ID"

log "Step 6: Invalidating CloudFront cache"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_ID" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)
log_success "Invalidation created: $INVALIDATION_ID"

log "Step 7: Waiting for invalidation to complete"
aws cloudfront wait invalidation-completed \
    --distribution-id "$CLOUDFRONT_ID" \
    --id "$INVALIDATION_ID"
log_success "Invalidation completed"

log "=========================================="
log_success "Frontend Deployment Complete!"
log "=========================================="
log "S3 Bucket: $S3_BUCKET"
log "CloudFront ID: $CLOUDFRONT_ID"
log "Files synced and cache invalidated"
log "=========================================="