# Feature Quickstart: GCP Foundation & WIF Setup

**Feature**: `001-gcp-bootstrap-wif`  

## Objective
Verify and execute the one-time GCP foundation setup, state bucket creation, service account provisioning, and Workload Identity Federation (WIF) setup.

## Prerequisites
- `gcloud` CLI logged into GCP with project admin privileges.
- Target GCP Project ID set in `GCP_PROJECT_ID` environment variable.
- Target GitHub repository formatted as `ORG/REPO` set in `GITHUB_REPO`.

## Bootstrap Execution

Run the shell script to bootstrap or verify the foundation resources:

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
export GITHUB_REPO="billnapier/NanoGemClawTF"

./scripts/bootstrap_gcp_foundation.sh
```

## Verification

Run the non-destructive verification script:

```bash
./scripts/verify_wif_bootstrap.sh
```

Expected output:
- GCP APIs verified enabled.
- State bucket `gs://${GCP_PROJECT_ID}-nanoclaw-tfstate` exists with versioning enabled.
- `terraform-deployer` service account exists and has IAM roles.
- WIF pool `github-pool` and provider `github-provider` exist with correct repo mapping.
