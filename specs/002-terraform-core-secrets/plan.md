# Implementation Plan: Terraform Core Infrastructure & Secret Manager Integration

**Branch**: `002-terraform-core-secrets` | **Date**: 2026-09-04 | **Spec**: [specs/002-terraform-core-secrets/spec.md](spec.md)
**Input**: Feature specification from `/specs/002-terraform-core-secrets/spec.md`

## Summary

Provision declarative GCP Terraform core resources for NanoGemClaw, including a least-privilege runtime Service Account (`nanoclaw-agent-runtime-sa`), Secret Manager containers & versions for `gemini-api-key` and `telegram-bot-token` with accessor IAM bindings, a 20GB persistent disk (`nanoclaw-data-disk`) with `prevent_destroy = true`, and an `e2-small` Compute Engine VM (`nanoclaw-gemini-agent`) with container startup script metadata fallback to `alpine:latest`.

## Technical Context

**Language/Version**: HCL (Terraform `>= 1.5.0`), Bash  
**Primary Dependencies**: `hashicorp/google` provider (`~> 5.0`)  
**Storage**: GCP Secret Manager, GCP Persistent Disk (`pd-standard`, 20GB), GCS backend for state  
**Testing**: `terraform validate`, `terraform fmt -check`, non-destructive HCL plan syntax checks  
**Target Platform**: Google Cloud Platform (GCP) Compute Engine & Secret Manager  
**Project Type**: Infrastructure / Terraform IaC  
**Performance Goals**: Fast startup script initialization, clean modular Terraform execution  
**Constraints**: Zero secrets hardcoded in git; `prevent_destroy` on persistent disk; dynamic SA Secret Accessor binding  
**Scale/Scope**: Single VM instance, 1 persistent data disk, 2 Secret Manager secrets  

## Constitution Check

| Principle | Status | Justification / Implementation Strategy |
|:---|:---|:---|
| **Principle 1: Declarative IaC & Guardian** | ✅ PASS | All infrastructure resources (VM, Disk, SA, Secret Manager, IAM) declared in HCL files under `terraform/`. |
| **Principle 2: Zero-Trust Security & WIF** | ✅ PASS | Secrets managed via GCP Secret Manager; access granted exclusively to runtime SA via `roles/secretmanager.secretAccessor`. |
| **Principle 3: Public Reusability** | ✅ PASS | All resource names, project IDs, container image tags, and secret IDs fully parameterized in `variables.tf`. |
| **Principle 4: Decoupled State** | ✅ PASS | Data disk `nanoclaw-data-disk` declared independently from Compute Engine VM with `lifecycle { prevent_destroy = true }`. |
| **Principle 5: Least-Privilege IAM** | ✅ PASS | Runtime SA `nanoclaw-agent-runtime-sa` created specifically for agent execution with minimal scope (Secret Accessor only). |
| **Principle 6: Predictable Cost** | ✅ PASS | Standard cost-effective VM (`e2-small`), 20GB `pd-standard` disk, standard Secret Manager API operations. |
| **Principle 7: One-Time Bootstrap & Skill** | ✅ PASS | Decoupled infrastructure phase allows Phase 1 apply before Phase 2 container build workflows. |

## Project Structure

### Documentation & Spec Artifacts

```text
specs/002-terraform-core-secrets/
├── plan.md              # Implementation Plan
├── research.md          # Architectural research & Secret/Disk lifecycle mapping
├── data-model.md        # GCP entities & IAM binding specs
├── quickstart.md        # Feature-specific quickstart instructions
└── tasks.md             # Task breakdown (generated in Phase 2)
```

### Source Code Layout

```text
terraform/
├── main.tf              # Provider configuration, GCS backend, Compute Instance & Persistent Disk
├── variables.tf         # Top-level input variables (container image, secret names, VM specs)
├── outputs.tf           # Terraform output values (VM IP, SA email, Secret IDs, Disk link)
├── iam.tf               # Runtime SA & Secret Accessor IAM bindings
├── secret_manager.tf    # Secret Manager secret containers & initial versions
scripts/
└── startup.sh           # Compute Engine metadata startup script for container runner & disk mounting
```

**Structure Decision**: Standard modular Terraform layout separating resources by domain (`iam.tf`, `secret_manager.tf`, `main.tf`).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|:---|:---|:---|
| None | N/A | Fully aligned with Constitution. |
