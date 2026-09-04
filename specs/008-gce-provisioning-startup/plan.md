# Implementation Plan: Compute Engine Provisioning & Startup Harness

## Technical Approach

We will provision an `e2-small` Compute Engine VM (`nanoclaw-gemini-agent`) with an attached 20GB persistent disk (`nanoclaw-data-disk`, device name `agent-data`), bounded runtime service account (`nanoclaw-agent-runtime-sa`), and a dynamically rendered startup script (`scripts/startup.sh`).

The startup script will be rendered via `templatefile` supplying both `${allowed_user_ids}` and `${container_image}` as required by Spec 008.

## Proposed Changes

### `terraform/variables.tf`
- Add `allowed_user_ids` variable (string, default `""`).

### `terraform/main.tf`
- Update `google_compute_instance.nanoclaw_vm`:
  - `attached_disk` device_name set to `"agent-data"`.
  - `metadata_startup_script` (or `metadata.startup-script`) templatefile parameters pass `allowed_user_ids = var.allowed_user_ids`, `container_image = var.container_image`, and `persistent_disk_name = google_compute_disk.agent_data.name`.

### `scripts/startup.sh`
- Accept `${allowed_user_ids}` and `${container_image}` in header template documentation and render them into environment configuration.
- Target device name `/dev/disk/by-id/google-agent-data`.

## Verification Plan

1. Run `cd terraform && terraform validate` to ensure HCL syntactical correctness.
2. Run `terraform fmt -check` to verify code formatting.
