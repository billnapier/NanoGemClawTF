# Implementation Plan: GCP Foundation & Workload Identity Federation Setup

**Branch**: `001-gcp-bootstrap-wif` | **Date**: 2026-09-04 | **Spec**: [specs/001-gcp-bootstrap-wif/spec.md](spec.md)
**Input**: Feature specification from `/specs/001-gcp-bootstrap-wif/spec.md`

## Summary

Establish GCP foundational infrastructure and zero-trust keyless authentication via Workload Identity Federation (WIF) for GitHub Actions CI/CD pipelines. This includes providing automated GCP bootstrap scripts, non-destructive verification tools, updated quickstart guides, and initial Terraform foundation declarations in accordance with Project Constitution Principle 7.

## Technical Context

**Language/Version**: HCL (Terraform `>= 1.5.0`), Bash (`gcloud` CLI)  
**Primary Dependencies**: `hashicorp/google` provider (`~> 5.0`)  
**Storage**: GCP Cloud Storage (GCS) for Terraform state  
**Testing**: `terraform validate`, non-destructive `gcloud` verification scripts (`scripts/verify_wif_bootstrap.sh`)  
**Target Platform**: Google Cloud Platform (GCP) & GitHub Actions CI/CD  
**Project Type**: Infrastructure / Single Project  
**Performance Goals**: WIF token exchange completes in < 5 seconds  
**Constraints**: Zero static JSON keys committed or generated; 100% parameterization for public forkability  
**Scale/Scope**: Bootstrap setup for 1 GCP Project & 1 GitHub Repository  

## Constitution Check

| Principle | Status | Justification / Implementation Strategy |
|:---|:---|:---|
| **Principle 1: Declarative IaC & Guardian** | ✅ PASS | Core resources declared in Terraform; bootstrap setup automated via version-controlled bash scripts & verification tools. |
| **Principle 2: Zero-Trust Security & WIF** | ✅ PASS | WIF OIDC token exchange implemented; zero long-lived JSON service account key files generated. |
| **Principle 3: Public Reusability** | ✅ PASS | All GCP Project IDs, buckets, repo paths fully parameterized (`${GCP_PROJECT_ID}`, `${GITHUB_REPO}`). |
| **Principle 4: Decoupled State** | ✅ PASS | Dedicated versioned GCS state bucket created for Terraform backend locking. |
| **Principle 5: Least-Privilege IAM** | ✅ PASS | `terraform-deployer` SA granted specific scope required for provisioning; WIF strictly scoped to `attribute.repository`. |
| **Principle 6: Predictable Cost** | ✅ PASS | GCS state bucket uses standard low-cost storage (~$0.02/month). WIF is free of charge. |
| **Principle 7: One-Time Bootstrap & Skill** | ✅ PASS | Dual-documented in `docs/quickstart.md` and automated via executable script `scripts/bootstrap_gcp_foundation.sh` and `scripts/verify_wif_bootstrap.sh`. |

## Project Structure

### Documentation & Spec Artifacts

```text
specs/001-gcp-bootstrap-wif/
├── plan.md              # Implementation Plan
├── research.md          # Architectural research & WIF mapping
├── data-model.md        # GCP entities & IAM binding specs
├── quickstart.md        # Feature-specific quickstart instructions
└── tasks.md             # Task breakdown (generated in Phase 2)
```

### Source Code Layout

```text
scripts/
├── bootstrap_gcp_foundation.sh   # Automated GCP bootstrap script
└── verify_wif_bootstrap.sh      # Non-destructive verification script

terraform/
├── main.tf                      # Terraform provider & backend configuration placeholder
├── variables.tf                 # Top-level input variables
└── outputs.tf                   # Core output values (WIF provider, SA email, state bucket)

docs/
└── quickstart.md                # Updated maintainer quickstart guide
```

**Structure Decision**: Infrastructure project layout using root `terraform/` directory for IaC files and `scripts/` directory for bootstrap and verification utilities.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|:---|:---|:---|
| None | N/A | Fully aligned with Constitution. |
