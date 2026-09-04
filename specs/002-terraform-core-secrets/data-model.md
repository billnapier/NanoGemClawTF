# Data Model: Core Infrastructure & Secret Manager Entities

**Feature**: `002-terraform-core-secrets`  
**Date**: 2026-09-04  

## GCP Infrastructure Entities

### 1. Runtime Service Account (`google_service_account.agent_runtime_sa`)
- **Account ID**: `nanoclaw-agent-runtime-sa`
- **Display Name**: `NanoGemClaw Agent Runtime Service Account`
- **Description**: Least-privilege service account assigned to the Compute Engine VM host for runtime secret fetching.
- **Roles**:
  - `roles/secretmanager.secretAccessor` (bound directly on secret resources)

### 2. Secret Manager Containers & Versions
- **Secret 1**: `google_secret_manager_secret.gemini_api_key`
  - **Secret ID**: `gemini-api-key`
  - **Replication**: `automatic`
- **Secret Version 1**: `google_secret_manager_secret_version.gemini_api_key_version`
  - **Secret Data**: Variable `var.gemini_api_key` (defaults to `placeholder-gemini-key`)
- **Secret 2**: `google_secret_manager_secret.telegram_bot_token`
  - **Secret ID**: `telegram-bot-token`
  - **Replication**: `automatic`
- **Secret Version 2**: `google_secret_manager_secret_version.telegram_bot_token_version`
  - **Secret Data**: Variable `var.telegram_bot_token` (defaults to `placeholder-telegram-token`)

### 3. Secret Accessor IAM Bindings (`google_secret_manager_secret_iam_member`)
- **Resource**: `google_secret_manager_secret.gemini_api_key.id` / `google_secret_manager_secret.telegram_bot_token.id`
- **Role**: `roles/secretmanager.secretAccessor`
- **Member**: `serviceAccount:${google_service_account.agent_runtime_sa.email}`

### 4. Agent Persistent Storage Disk (`google_compute_disk.agent_data`)
- **Name**: `nanoclaw-data-disk`
- **Type**: `pd-standard`
- **Size**: `20` (GB)
- **Zone**: `var.zone` (e.g. `us-central1-a`)
- **Lifecycle**: `prevent_destroy = true`

### 5. Compute Engine Instance (`google_compute_instance.nanoclaw_vm`)
- **Name**: `nanoclaw-gemini-agent`
- **Machine Type**: `e2-small`
- **Zone**: `var.zone`
- **Boot Disk**: `debian-cloud/debian-12` image (10GB)
- **Attached Disk**: `google_compute_disk.agent_data` (Device name: `sdb` / `nanoclaw-data`)
- **Service Account**: `google_service_account.agent_runtime_sa.email` with `cloud-platform` scopes
- **Metadata**: `startup-script` set to rendered `scripts/startup.sh`
