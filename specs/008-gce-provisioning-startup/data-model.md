# Data Model: GCE Provisioning Infrastructure Entities

## Entities

### `google_compute_instance.nanoclaw_vm`
- `name`: `nanoclaw-gemini-agent`
- `machine_type`: `e2-small`
- `zone`: `var.zone`
- `boot_disk`: Debian 12 (10GB)
- `attached_disk`: `nanoclaw-data-disk` as `agent-data`
- `service_account`: `nanoclaw-agent-runtime-sa` with `cloud-platform` scope
- `metadata.startup-script`: Dynamically rendered `startup.sh`

### `google_compute_disk.agent_data`
- `name`: `nanoclaw-data-disk`
- `type`: `pd-standard`
- `size`: 20GB
