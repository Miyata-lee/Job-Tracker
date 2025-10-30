#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-jobtracker}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"
CF_ALIAS_MATCH="${CF_ALIAS_MATCH:-}"

log(){ echo "[$(date +'%F %T')] $*"; }

command -v aws >/dev/null || { echo "AWS CLI not installed"; exit 1; }

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="${PROJECT_NAME}-frontend-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
aws s3 ls "s3://${S3_BUCKET}" >/dev/null || { echo "Bucket not found s3://${S3_BUCKET}"; exit 1; }

log "Syncing application/static and application/templates -> s3://${S3_BUCKET}"

# Upload static files
aws s3 sync application/static "s3://${S3_BUCKET}/static" \
  --region "${AWS_REGION}" \
  --delete \
  --cache-control "max-age=3600,s-maxage=3600"

# Upload templates
aws s3 sync application/templates "s3://${S3_BUCKET}/templates" \
  --region "${AWS_REGION}" \
  --delete \
  --cache-control "max-age=3600,s-maxage=3600"

# Optional invalidation
if [ -n "${CF_ALIAS_MATCH}" ]; then
  CLOUDFRONT_ID=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Aliases.Items[?contains(@, \`${CF_ALIAS_MATCH}\`)]].Id | [0]" \
    --output text)
  if [ -n "${CLOUDFRONT_ID}" ] && [ "${CLOUDFRONT_ID}" != "None" ]; then
    log "Invalidating CloudFront ${CLOUDFRONT_ID}"
    aws cloudfront create-invalidation --distribution-id "${CLOUDFRONT_ID}" --paths "/*" >/dev/null
  fi
fi

log "Frontend deployment complete"