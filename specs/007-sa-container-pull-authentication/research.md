# Research & Technology Selection: Compute Engine SA Container Pull & Image Verification

## 1. Declarative Container Image Binding
- **Terraform Variable**: `container_image` in `terraform/variables.tf`.
- **Default Value**: `ghcr.io/billnapier/nanogemclaw:latest`.
- **Override Support**: Injected via `TF_VAR_container_image` or Terraform configuration files.

## 2. GHCR Container Image Pull & Authentication Strategy
- **Registry Endpoint**: GitHub Container Registry (`ghcr.io`).
- **Package Visibility**: GitHub Container Registry package visibility for `billnapier/nanogemclaw`. Public or authenticated pull access via standard container tools.
- **Host Execution**: Compute Engine VM startup script executes `docker pull ${container_image}` in non-interactive mode.

## 3. Host Systemd & Startup Verification
- `startup.sh` pulls default image `ghcr.io/billnapier/nanogemclaw:latest`.
- Non-zero fallback handling included to ensure host boot resilience.
