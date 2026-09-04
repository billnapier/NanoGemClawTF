# Research: GCP Foundation & Workload Identity Federation Setup

**Feature**: `001-gcp-bootstrap-wif`  
**Date**: 2026-09-04  

## 1. Workload Identity Federation (WIF) Architecture

### GitHub OIDC Token Exchange
- **Issuer**: `https://token.actions.githubusercontent.com`
- **Audience**: `https://iam.googleapis.com/projects/{PROJECT_NUMBER}/locations/global/workloadIdentityPools/{POOL_ID}/providers/{PROVIDER_ID}`
- **Attribute Mapping**:
  - `google.subject`: `assertion.sub`
  - `attribute.actor`: `assertion.actor`
  - `attribute.repository`: `assertion.repository`
  - `attribute.repository_owner`: `assertion.repository_owner`
- **IAM Principal Binding**:
  - `principalSet://iam.googleapis.com/projects/{PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/{GITHUB_REPO}` mapped to `roles/iam.workloadIdentityUser` on `terraform-deployer@{PROJECT_ID}.iam.gserviceaccount.com`.

## 2. GCS State Bucket Security & Configuration

- **Location**: Multi-region or regional (e.g. `us-central1`).
- **Versioning**: Enabled (ensures state restoration in case of accidental deletion/corruption).
- **Public Access Prevention**: Enforced (enforce uniform bucket-level access).
- **Encryption**: Google-managed encryption keys (CMEK optional for high security).

## 3. Terraform Deployer IAM Roles

- `roles/editor`: Project editor for compute, storage, secret manager resource creation.
- `roles/resourcemanager.projectIamAdmin`: Project IAM admin to bind runtime SA permissions.

## 4. Operational & Bootstrap Automation Strategy

- **Dual-Documentation & Automation**:
  - Human guide: `docs/quickstart.md`
  - AI / Skill guide: `specs/001-gcp-bootstrap-wif/quickstart.md`
- **Automated Verification Script**: A lightweight bash verification script (`scripts/verify_wif_bootstrap.sh`) to query GCP API and verify state bucket, SA bindings, and WIF pool status non-destructively.
