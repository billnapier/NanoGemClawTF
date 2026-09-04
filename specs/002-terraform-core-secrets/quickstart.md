# Quickstart: Core Infrastructure & Secret Manager Integration

**Feature**: `002-terraform-core-secrets`  

## Validation Instructions

### 1. Terraform HCL Format and Syntax Check
Validate Terraform declarations without requiring active cloud execution:

```bash
cd terraform
terraform fmt -check
terraform validate
```

### 2. Terraform Execution Plan Inspection
Inspect planned resources and verify `prevent_destroy` on persistent disk and fallback container image parameter:

```bash
cd terraform
terraform init -backend=false
terraform plan -var="project_id=mock-project-id"
```

Expected Plan Output:
- `google_service_account.agent_runtime_sa` created
- `google_secret_manager_secret` (`gemini-api-key`, `telegram-bot-token`) created
- `google_secret_manager_secret_iam_member` binding `roles/secretmanager.secretAccessor` created
- `google_compute_disk.agent_data` (20GB pd-standard) created with `prevent_destroy = true`
- `google_compute_instance.nanoclaw_vm` created with `alpine:latest` fallback image in startup script metadata
