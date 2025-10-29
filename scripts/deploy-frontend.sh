#!/usr/bin/env bash
# JobTracker S3 + CloudFront Frontend Deployment

set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-jobtracker}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"
FRONTEND_DIR="${FRONTEND_DIR:-application/frontend-app/templates}"
CF_ALIAS_MATCH="${CF_ALIAS_MATCH:-}"

log(){ echo "[$(date +'%F %T')] $*"; }

command -v aws >/dev/null || { echo "AWS CLI not installed"; exit 1; }
[ -d "$FRONTEND_DIR" ] || { echo "Missing $FRONTEND_DIR"; exit 1; }

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="${PROJECT_NAME}-frontend-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
aws s3 ls "s3://${S3_BUCKET}" >/dev/null || { echo "Bucket not found s3://${S3_BUCKET}"; exit 1; }

log "Syncing ${FRONTEND_DIR} -> s3://${S3_BUCKET}"
aws s3 sync "${FRONTEND_DIR}" "s3://${S3_BUCKET}" \
  --region "${AWS_REGION}" \
  --delete \
  --cache-control "max-age=3600,s-maxage=3600"

# Optional invalidation (CloudFront already working)
if [ -n "${CF_ALIAS_MATCH}" ]; then
  CLOUDFRONT_ID=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Aliases.Items[?contains(@, \`${CF_ALIAS_MATCH}\`)]].Id | [0]" \
    --output text)
  if [ -n "${CLOUDFRONT_ID}" ] && [ "${CLOUDFRONT_ID}" != "None" ]; then
    log "Invalidating CloudFront ${CLOUDFRONT_ID}"
    aws cloudfront create-invalidation --distribution-id "${CLOUDFRONT_ID}" --paths "/*" >/dev/null
  else
    log "No matching CloudFront distribution found; skipping invalidation"
  fi
fi

log "Frontend deployment complete"
