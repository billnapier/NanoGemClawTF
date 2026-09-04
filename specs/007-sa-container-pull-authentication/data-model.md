# Data Model: Container Pull & Host Deployment Entities

## Key Entities

### Container Image Variable
- **Name**: `container_image`
- **Type**: String
- **Default**: `ghcr.io/billnapier/nanogemclaw:latest`
- **Description**: Container image reference used by Compute Engine host VM.

### Host Startup Service
- **Script**: `scripts/startup.sh`
- **Target Image**: Bound dynamically from Terraform variable `${container_image}`.
- **Execution Flow**:
  1. Mount persistent storage disk (`/var/lib/nanoclaw-data`).
  2. Install Docker runtime if absent.
  3. Pull `${container_image}` from `ghcr.io`.
