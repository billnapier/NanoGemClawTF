# Feature Quickstart: Initial Infrastructure Provisioning & Fallback Verification (`004-phase1-validation-apply`)

> [!IMPORTANT]
> **Synchronization Policy**: Per Constitution Principle 7, all manual operational and verification steps MUST be documented here and kept in 100% continuous synchronization with executable skills (`nanogemclaw.bootstrap`).

This guide details how to verify repository secret bootstrapping and execute non-destructive end-to-end verification of Phase 1 GCP infrastructure provisioning.

---

## 1. Pre-Flight Secret & Variable Check

Ensure all required repository variables and secrets are populated in your GitHub Repository (**Settings → Secrets and variables → Actions**):

- **Variables**: `GCP_PROJECT_ID`, `GCP_REGION`, `GCP_ZONE`, `GCP_WIF_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `GCP_TF_STATE_BUCKET`, `ALLOWED_USER_IDS`
- **Secrets**: `GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`

---

## 2. Automated Phase 1 Verification

Run the non-destructive Phase 1 verification script from the repository root:

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
export GCP_ZONE="us-central1-a"
export GCP_TF_STATE_BUCKET="your-gcp-project-id-nanoclaw-tfstate"

./scripts/verify_phase1_deployment.sh
```

---

## 3. Expected Verification Outputs

- **Compute Instance**: Status `RUNNING` for VM `nanoclaw-gemini-agent`
- **Persistent Disk**: Attached 20GB disk `nanoclaw-data-disk`
- **Secret Manager**: Version 1 payload present for `gemini-api-key` and `telegram-bot-token`
- **GCS Remote State**: `default.tfstate` exists in `gs://${GCP_TF_STATE_BUCKET}`
- **VM Serial Log Output**: `startup.sh` registered systemd mount `/opt/nanoclaw/data` with exit code 0
