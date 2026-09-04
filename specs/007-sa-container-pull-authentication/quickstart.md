# Quickstart Guide: Compute Engine SA Container Pull Verification

## Overview
This guide documents how to verify default GHCR container image bindings in Terraform.

## Terraform Verification
Run the following commands in `terraform/`:
```bash
terraform fmt -check
terraform validate
```

To test custom image overrides:
```bash
export TF_VAR_container_image="ghcr.io/billnapier/nanogemclaw:sha-01e3ab6"
terraform plan
```
