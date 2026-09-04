#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# NanoGemClawTF GCP Foundation Bootstrap Script
# ==============================================================================
# Automates non-IaC GCP bootstrap requirements: API enablement, GCS state bucket,
# terraform-deployer SA creation, IAM delegation, and WIF pool/provider setup.
# ==============================================================================

if [ -z "${GCP_PROJECT_ID:-}" ]; then
  echo "Error: GCP_PROJECT_ID environment variable is required."
  echo "Usage: GCP_PROJECT_ID=\"your-project-id\" GITHUB_REPO=\"org/repo\" $0"
  exit 1
fi

GITHUB_REPO="${GITHUB_REPO:-billnapier/NanoGemClawTF}"
LOCATION="${GCP_REGION:-us-central1}"
BUCKET_NAME="${GCP_TF_STATE_BUCKET:-${GCP_PROJECT_ID}-nanoclaw-tfstate}"
SA_NAME="terraform-deployer"
SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

echo "=== 🚀 Starting GCP Foundation Bootstrap ==="
echo "Project ID : ${GCP_PROJECT_ID}"
echo "GitHub Repo: ${GITHUB_REPO}"
echo "Location   : ${LOCATION}"
echo "State Bucket: ${BUCKET_NAME}"
echo "==========================================="

gcloud config set project "${GCP_PROJECT_ID}" --quiet

echo "--> 1. Enabling required GCP Service APIs..."
gcloud services enable \
  compute.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  storage.googleapis.com

echo "--> 2. Provisioning Terraform GCS State Bucket..."
if gcloud storage buckets describe "gs://${BUCKET_NAME}" &>/dev/null; then
  echo "Bucket gs://${BUCKET_NAME} already exists."
else
  gcloud storage buckets create "gs://${BUCKET_NAME}" --location="${LOCATION}" --uniform-bucket-level-access
fi

echo "--> Enabling Object Versioning on State Bucket..."
gcloud storage buckets update "gs://${BUCKET_NAME}" --versioning

echo "--> 3. Creating Terraform Deployer Service Account..."
if gcloud iam service-accounts describe "${SA_EMAIL}" &>/dev/null; then
  echo "Service account ${SA_EMAIL} already exists."
else
  gcloud iam service-accounts create "${SA_NAME}" \
    --display-name="Terraform Deployer SA for GitHub Actions"
fi

echo "--> Granting IAM Roles to Deployer SA..."
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/editor" \
  --condition=None --quiet || true

gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --condition=None --quiet || true

gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin" \
  --condition=None --quiet || true

gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin" \
  --quiet || true

echo "--> 4. Setting up Workload Identity Federation..."
if gcloud iam workload-identity-pools describe "${POOL_NAME}" --location="global" &>/dev/null; then
  echo "WIF Pool ${POOL_NAME} already exists."
else
  gcloud iam workload-identity-pools create "${POOL_NAME}" \
    --location="global" \
    --display-name="GitHub Actions Pool"
fi

if gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" --location="global" --workload-identity-pool="${POOL_NAME}" &>/dev/null; then
  echo "WIF Provider ${PROVIDER_NAME} already exists."
else
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
    --location="global" \
    --workload-identity-pool="${POOL_NAME}" \
    --display-name="GitHub Actions Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"
fi

PROJECT_NUMBER=$(gcloud projects describe "${GCP_PROJECT_ID}" --format="value(projectNumber)")

echo "--> Binding WIF Principal to Terraform Deployer SA..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/attribute.repository/${GITHUB_REPO}" \
  --condition=None --quiet || true

echo ""
echo "=== 🎉 GCP Foundation Bootstrap Complete ==="
echo "WIF Provider Resource Name:"
echo "projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME}"
echo "==========================================="
