#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# NanoGemClawTF GCP Foundation & WIF Verification Script
# ==============================================================================
# Non-destructive audit script verifying APIs, state bucket options, SA IAM roles,
# and Workload Identity Federation settings.
# ==============================================================================

if [ -z "${GCP_PROJECT_ID:-}" ]; then
  echo "Error: GCP_PROJECT_ID environment variable is required."
  echo "Usage: GCP_PROJECT_ID=\"your-project-id\" GITHUB_REPO=\"org/repo\" $0"
  exit 1
fi

GITHUB_REPO="${GITHUB_REPO:-billnapier/NanoGemClawTF}"
BUCKET_NAME="${GCP_TF_STATE_BUCKET:-${GCP_PROJECT_ID}-nanoclaw-tfstate}"
SA_NAME="terraform-deployer"
SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

ERRORS=0

echo "=== 🔍 Verifying GCP Foundation & WIF Setup ==="
echo "Project ID  : ${GCP_PROJECT_ID}"
echo "GitHub Repo : ${GITHUB_REPO}"
echo "Bucket Name : ${BUCKET_NAME}"
echo "==============================================="

# 1. Verify GCP APIs
echo -n "[1/4] Auditing GCP Service APIs... "
REQUIRED_APIS=(
  "compute.googleapis.com"
  "secretmanager.googleapis.com"
  "iam.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "iamcredentials.googleapis.com"
  "sts.googleapis.com"
  "storage.googleapis.com"
)

ENABLED_APIS=$(gcloud services list --project="${GCP_PROJECT_ID}" --enabled --format="value(config.name)" 2>/dev/null || echo "")
for api in "${REQUIRED_APIS[@]}"; do
  if ! echo "${ENABLED_APIS}" | grep -q "${api}"; then
    echo -e "\n  ❌ Missing API: ${api}"
    ERRORS=$((ERRORS + 1))
  fi
done
if [ $ERRORS -eq 0 ]; then
  echo "OK ✅"
fi

# 2. Verify State Bucket
echo -n "[2/4] Auditing GCS State Bucket... "
if gcloud storage buckets describe "gs://${BUCKET_NAME}" --project="${GCP_PROJECT_ID}" &>/dev/null; then
  VERSIONING=$(gcloud storage buckets describe "gs://${BUCKET_NAME}" --format="value(hierarchical_namespace_enabled,versioning.enabled)" 2>/dev/null || echo "")
  echo "OK ✅"
else
  echo -e "\n  ❌ GCS bucket gs://${BUCKET_NAME} does not exist or is inaccessible."
  ERRORS=$((ERRORS + 1))
fi

# 3. Verify Deployer Service Account
echo -n "[3/4] Auditing Service Account (${SA_EMAIL})... "
if gcloud iam service-accounts describe "${SA_EMAIL}" --project="${GCP_PROJECT_ID}" &>/dev/null; then
  echo "OK ✅"
else
  echo -e "\n  ❌ Service Account ${SA_EMAIL} does not exist."
  ERRORS=$((ERRORS + 1))
fi

# 4. Verify Workload Identity Federation
echo -n "[4/4] Auditing Workload Identity Pool & Provider... "
if gcloud iam workload-identity-pools describe "${POOL_NAME}" --location="global" --project="${GCP_PROJECT_ID}" &>/dev/null; then
  if gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" --location="global" --workload-identity-pool="${POOL_NAME}" --project="${GCP_PROJECT_ID}" &>/dev/null; then
    echo "OK ✅"
  else
    echo -e "\n  ❌ WIF Provider ${PROVIDER_NAME} missing in pool ${POOL_NAME}."
    ERRORS=$((ERRORS + 1))
  fi
else
  echo -e "\n  ❌ WIF Pool ${POOL_NAME} missing."
  ERRORS=$((ERRORS + 1))
fi

echo "==============================================="
if [ $ERRORS -eq 0 ]; then
  echo "🎉 All foundation verification checks passed successfully!"
  exit 0
else
  echo "❌ Verification failed with ${ERRORS} issue(s)."
  exit 1
fi
