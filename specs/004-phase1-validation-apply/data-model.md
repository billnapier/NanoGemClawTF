# Data Model & Infrastructure State Schema: Feature 004

## 1. Primary Infrastructure Entities

### 1.1 Pre-Flight Repository Configuration
- **Repository Variables (`vars.*`)**:
  - `GCP_PROJECT_ID`: GCP target project identifier
  - `GCP_REGION`: Target GCP region (e.g. `us-central1`)
  - `GCP_ZONE`: Target GCP zone (e.g. `us-central1-a`)
  - `GCP_WIF_PROVIDER`: Workload Identity Federation provider string
  - `GCP_SERVICE_ACCOUNT`: Deployer service account email
  - `GCP_TF_STATE_BUCKET`: Remote state storage bucket name
  - `ALLOWED_USER_IDS`: Messaging platform user authorization list
- **Repository Secrets (`secrets.*`)**:
  - `GEMINI_API_KEY`: Google Gemini API key
  - `TELEGRAM_BOT_TOKEN`: Telegram bot auth token

### 1.2 Provisioned GCP Resources Graph
- **Compute Instance (`google_compute_instance.nanoclaw_vm`)**:
  - Name: `nanoclaw-gemini-agent`
  - Machine Type: `e2-small`
  - Zone: `var.gcp_zone`
  - Status: `RUNNING`
  - Startup Script: `startup.sh`
- **Persistent Disk (`google_compute_disk.nanoclaw_data_disk`)**:
  - Name: `nanoclaw-data-disk`
  - Size: 20GB `pd-standard`
  - Mount Path: `/opt/nanoclaw/data`
- **Secret Manager Secrets (`google_secret_manager_secret.*`)**:
  - `gemini-api-key`: Version 1 payload populated dynamically
  - `telegram-bot-token`: Version 1 payload populated dynamically

### 1.3 GCS Remote State Persistence
- **Storage Bucket (`gs://${GCP_TF_STATE_BUCKET}`)**:
  - Object Path: `default.tfstate`
  - Features: Versioning enabled, uniform bucket-level access

## 2. Status & Verification Lifecycle States

```text
[ Pre-Flight Validation ] ──(PASS)──> [ Guardian Plan ] ──(MERGE)──> [ Guardian Apply ] ──> [ GCP Provisioned ] ──> [ Audit Verification ]
```
