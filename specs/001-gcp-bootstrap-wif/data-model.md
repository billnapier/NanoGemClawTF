# Data Model & Infrastructure Entities: GCP Foundation & WIF Setup

**Feature**: `001-gcp-bootstrap-wif`  
**Date**: 2026-09-04  

## Infrastructure Entities & Configuration Parameters

### 1. GCP Service APIs
- `compute.googleapis.com`
- `secretmanager.googleapis.com`
- `iam.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `iamcredentials.googleapis.com`
- `sts.googleapis.com`
- `storage.googleapis.com`

### 2. GCS State Bucket
- **Bucket Identifier**: `${PROJECT_ID}-nanoclaw-tfstate`
- **Location**: `us-central1`
- **Versioning Enabled**: `true`
- **Uniform Bucket-Level Access**: `true`
- **Public Access Prevention**: `enforced`

### 3. Deployer Service Account
- **Account ID**: `terraform-deployer`
- **Display Name**: `Terraform Deployer SA for GitHub Actions`
- **Email Format**: `terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com`
- **Assigned Project Roles**:
  - `roles/editor`
  - `roles/resourcemanager.projectIamAdmin`

### 4. Workload Identity Pool & Provider
- **Pool ID**: `github-pool`
- **Pool Display Name**: `GitHub Actions Pool`
- **Provider ID**: `github-provider`
- **Provider Display Name**: `GitHub Actions Provider`
- **Issuer URI**: `https://token.actions.githubusercontent.com`
- **Attribute Mappings**:
  - `google.subject` = `assertion.sub`
  - `attribute.actor` = `assertion.actor`
  - `attribute.repository` = `assertion.repository`
  - `attribute.repository_owner` = `assertion.repository_owner`
- **WIF Principal Binding**:
  - **Role**: `roles/iam.workloadIdentityUser`
  - **Member**: `principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}`
