# Research: GCE VM Provisioning & Startup Template Injection

## Key Findings

1. **GCE Device Naming**: GCE attached persistent disks appear under `/dev/disk/by-id/google-<device_name>`. Setting `device_name = "agent-data"` maps to `/dev/disk/by-id/google-agent-data`.
2. **Terraform Templatefile**: `templatefile` evaluates template files with string substitution. Passing `allowed_user_ids` alongside `container_image` ensures all runtime parameters are supplied during instance initialization.
