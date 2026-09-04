# Technical Research: Initial Infrastructure Provisioning & Fallback Verification

## 1. Overview

This document outlines technical research, decisions, and verification mechanisms for Phase 1.4: Initial Infrastructure Provisioning & Fallback Verification (`004-phase1-validation-apply`).

## 2. Technical Decisions

### Decision 1: Pre-Flight Secret & Variable Validation
- **Context**: Executing `terraform apply` via Guardian workflow without configured GitHub repository secrets (`GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`) or variables causes runtime execution failures or empty secret payloads in GCP Secret Manager.
- **Decision**: Incorporate pre-flight check logic into CI/CD workflows and verification scripts (`scripts/verify_wif_bootstrap.sh` and pre-check steps) to validate that all required `vars.*` and `secrets.*` are defined before proceeding with Guardian execution.
- **Rationale**: Ensures early feedback to operators and zero half-provisioned infrastructure states.

### Decision 2: Fallback Image Selection for Initial VM Host Provisioning
- **Context**: During Phase 1 initialization, custom application container images (`nanoclaw-app`) may not yet be compiled or pushed to Google Artifact Registry.
- **Decision**: Use `alpine:latest` as the default fallback container image specified in `variables.tf` / `terraform.tfvars`.
- **Rationale**: Allows 100% independent validation of VM compute instance creation, systemd startup script execution (`startup.sh`), and persistent storage mount attachment (`/opt/nanoclaw/data`) without blocking on application build pipelines.

### Decision 3: Non-Destructive Post-Deploy Audit Scripting
- **Context**: Operators and CI/CD pipelines need a verifiable, repeatable method to check GCP resource status (VM state, persistent disk attachment, Secret Manager versions, GCS state file) after `terraform apply`.
- **Decision**: Create/expand a non-destructive audit script `scripts/verify_phase1_deployment.sh` using `gcloud` CLI commands.
- **Rationale**: Delivers automated, reproducible verification for User Stories 1, 2, and 3 without manual console navigation.

## 3. Technology Stack & Verification Tools

- **CLI Tools**: `gcloud compute instances describe`, `gcloud secrets versions list`, `gcloud storage ls`
- **Verification Script**: `scripts/verify_phase1_deployment.sh`
- **Fallback Image**: `alpine:latest`
