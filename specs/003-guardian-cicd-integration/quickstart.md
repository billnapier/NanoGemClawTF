# Quickstart: Guardian CI/CD Workflows

## Prerequisites Verification

Ensure the following GitHub Repository Variables (`vars.*`) and Secrets (`secrets.*`) are configured in your repository settings before triggering CI workflows:

### Required GitHub Repository Variables (`vars.*`)
- `GCP_WIF_PROVIDER`: Full resource name of the Workload Identity Provider (e.g., `projects/12345/locations/global/workloadIdentityPools/github-pool/providers/github-provider`).
- `GCP_WIF_SERVICE_ACCOUNT`: Service account email used for CI/CD operations (e.g., `nanoclaw-deployer@my-project.iam.gserviceaccount.com`).
- `GCP_PROJECT_ID`: Target GCP Project ID (e.g., `my-nanoclaw-project`).
- `GCP_TF_STATE_BUCKET`: GCS Bucket name for Terraform backend state.
- `GCP_REGION`: Target GCP Region (default: `us-central1`).
- `GCP_ZONE`: Target GCP Zone (default: `us-central1-a`).
- `ALLOWED_USER_IDS`: Comma-separated list of allowed Telegram user IDs.

### Required GitHub Repository Secrets (`secrets.*`)
- `GEMINI_API_KEY`: Secret API key for Google Gemini access.
- `TELEGRAM_BOT_TOKEN`: Secret Telegram bot token.

## Manual Testing & Workflow Triggers

1. **Test Plan Workflow**: Open a Pull Request changing any `.tf` file in `terraform/`. Verify that `terraform-plan.yml` runs successfully and posts the plan diff as a comment.
2. **Test Apply Workflow**: Merge the Pull Request to `main`. Verify that `terraform-apply.yml` runs and applies changes dynamically using the GCS state bucket.
