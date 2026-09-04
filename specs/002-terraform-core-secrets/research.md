# Research: Core Infrastructure & Secret Manager Integration

**Feature**: `002-terraform-core-secrets`  
**Date**: 2026-09-04  

## 1. GCP Secret Manager Architecture & IAM Bindings

### Resources & Access Control
- `google_secret_manager_secret`: Declarative container for secrets (`gemini-api-key`, `telegram-bot-token`).
- `google_secret_manager_secret_version`: Initial payload placeholders (`placeholder-gemini-key`, `placeholder-telegram-token`) when variables are not supplied, allowing initial apply without committing sensitive runtime secrets to source code.
- `google_secret_manager_secret_iam_binding` / `google_secret_manager_secret_iam_member`:
  - Grant `roles/secretmanager.secretAccessor` to `serviceAccount:${google_service_account.agent_runtime_sa.email}`.
  - Ensures runtime instance can dynamically fetch keys via standard GCP client libraries or `gcloud` CLI.

## 2. Decoupled Compute Engine VM & Persistent Disk Lifecycle

### Persistent Disk Configuration
- Resource: `google_compute_disk.agent_data`
- Type: `pd-standard` (20GB)
- Lifecycle protection: `lifecycle { prevent_destroy = true }` prevents accidental state wipe when running `terraform destroy` or replacing VM instances.
- Mounting pattern: Attached to Compute Engine instance via `attached_disk` block in `google_compute_instance`.

### Compute Engine VM Configuration
- Resource: `google_compute_instance.nanoclaw_vm`
- Machine Type: `e2-small`
- OS Image: `debian-cloud/debian-12`
- Service Account Binding: Assigned `nanoclaw-agent-runtime-sa` with `https://www.googleapis.com/auth/cloud-platform` scope.

## 3. Metadata Startup Script & Container Fallback

### Startup Script Pattern (`scripts/startup.sh`)
- Formatted as a template using `templatefile("${path.module}/../scripts/startup.sh", { ... })`.
- Parameters injected: `container_image`, `persistent_disk_name`.
- Startup script actions:
  1. Format persistent disk (if unformatted ext4) and mount to `/var/lib/nanoclaw-data`.
  2. Install Docker / Container Runtime (or run container engine).
  3. Pull fallback container image (`alpine:latest` default, or custom GHCR image).
  4. Fetch secrets dynamically from Secret Manager at container launch.

## 4. Phase 1 vs. Phase 2 Decoupling Strategy

- By configuring `var.container_image` default to `alpine:latest`, `terraform plan` and `terraform apply` can complete and be validated in Phase 1 before GHCR container build workflows exist.
