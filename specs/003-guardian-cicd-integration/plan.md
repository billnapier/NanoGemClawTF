# Implementation Plan: Guardian CI/CD Workflows & Policy Integration

**Branch**: `003-guardian-cicd-integration` | **Date**: 2026-09-04 | **Spec**: [specs/003-guardian-cicd-integration/spec.md](file:///home/napier/a/NanoGemClawTF/specs/003-guardian-cicd-integration/spec.md)
**Input**: Feature specification from `/specs/003-guardian-cicd-integration/spec.md`

## Summary

Automate Infrastructure-as-Code delivery by implementing GitHub Actions workflows (`terraform-plan.yml` and `terraform-apply.yml`) using `abcxyz/guardian`, Workload Identity Federation (WIF) keyless authentication, dynamic GCS state backend injection, and repository parameter binding.

## Technical Context

**Language/Version**: HCL (Terraform `>= 1.5.0`), YAML (GitHub Actions)  
**Primary Dependencies**: `abcxyz/guardian/actions/setup@v1`, `google-github-actions/auth@v2`, `actions/checkout@v4`  
**Storage**: GCP Cloud Storage (GCS) for Terraform Remote State  
**Testing**: `terraform validate`, `terraform fmt -check`, Actionlint / GitHub Actions workflow syntax validation  
**Target Platform**: GitHub Actions CI/CD Runner (Debian Linux)  
**Project Type**: Infrastructure-as-Code & GitOps CI/CD  
**Performance Goals**: CI Plan workflow completion within < 3 minutes  
**Constraints**: Zero hardcoded secrets/IDs, 100% public forkability, keyless WIF authentication  
**Scale/Scope**: Automated PR validation and post-merge deployment pipelines  

## Constitution Check

- **Principle 1 (Declarative IaC & Guardian-Driven GitOps Deployment)**: Pass. Workflows execute `guardian entrypoints plan` and `guardian entrypoints apply`.
- **Principle 2 (Zero-Trust Security & Secret Isolation)**: Pass. Uses keyless OIDC authentication via WIF (`google-github-actions/auth@v2`) and GCP Secret Manager for application secrets.
- **Principle 3 (Public Reusability, Forkability & Zero Private Leakage)**: Pass. All state buckets, project IDs, WIF identifiers, and tokens are dynamically injected from `vars.*` and `secrets.*`.
- **Principle 8 (Mandatory Comprehensive Automated Testing & Required PR Gates)**: Pass. Workflows enforce syntax, validation, and policy checks as required status checks.
- **Principle 9 (Clean Git History, PR Hygiene & Upstream Sync)**: Pass. Branch rebased cleanly on latest `origin/main`.

## Project Structure

### Documentation (this feature)

```text
specs/003-guardian-cicd-integration/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Technology decisions
├── data-model.md        # Entities & workflow configurations
├── quickstart.md        # Operator setup & testing guide
└── tasks.md             # Task breakdown
```

### Source Code

```text
.github/
└── workflows/
    ├── terraform-plan.yml   # PR plan review workflow using Guardian
    └── terraform-apply.yml  # Main branch apply workflow using Guardian
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
