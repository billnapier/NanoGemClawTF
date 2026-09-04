# Implementation Plan: Compute Engine SA Container Pull & Image Verification

## Overview
Update `terraform/variables.tf` default value for `container_image` to point to published GHCR image `ghcr.io/billnapier/nanogemclaw:latest`. Verify startup script integration and run Terraform syntax/plan checks.

## Key Changes
1. **Terraform Variable Binding**:
   - Change `default = "alpine:latest"` to `default = "ghcr.io/billnapier/nanogemclaw:latest"` in `terraform/variables.tf`.
   - Update variable description to reflect live GHCR default.
2. **Startup Script**:
   - Verify `scripts/startup.sh` pulls `${container_image}` successfully.
3. **Validation**:
   - Run `terraform validate` and `terraform plan` to confirm HCL validity.

## Verification Plan
- `terraform validate` passes.
- `terraform plan` displays default `container_image` pointing to `ghcr.io/billnapier/nanogemclaw:latest`.
