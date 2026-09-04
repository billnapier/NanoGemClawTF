# Project Roadmap: GitOps & Terraform Infrastructure for NanoClaw with Gemini on GCP

## Executive Summary & Program Execution Decisions

This document outlines the milestone-driven roadmap for deploying and operating the **NanoGemClaw** agent infrastructure on Google Cloud Platform using declarative Terraform IaC and GitHub Actions CI/CD with `abcxyz/guardian`.

### Ratified TPM Execution Decisions

| Decision Area | Agreed Strategy | Rationale & Impact |
| :--- | :--- | :--- |
| **Q1: Phase 1 IaC vs. Container Image Dependency** | **Decoupled Phase 1 with Fallback Image** | Isolates IAM, WIF, Secret Manager, and Guardian pipeline verification from container build repo setup using a standard fallback image (`alpine:latest`) during initial apply. |
| **Q2: Secret Bootstrapping Sequence** | **Declarative GHA Secret Binding** | Populates `GEMINI_API_KEY` and `TELEGRAM_BOT_TOKEN` in GitHub Repository Secrets prior to Phase 1 apply, ensuring GCP Secret Manager versions are cleanly provisioned by Terraform. |
| **Q3: Persistence Recovery Verification** | **Disruption & Host Reboot Test** | Validates systemd `opt-nanoclaw-data.mount` and persistent disk state survival under forced VM reboot before Phase 4 E2E signoff. |

---

## Roadmap Overview & Dependency Flow

```mermaid
graph TD
    subgraph "Phase 1: Foundation & GitOps IaC Pipeline"
        P1A[1.1 GCP Bootstrap & WIF] --> P1B[1.2 Terraform Core & Secrets]
        P1B --> P1C[1.3 Guardian CI/CD Integration]
        P1C --> P1D[1.4 Phase 1 Validation & Apply]
    end

    subgraph "Phase 2: Container Build & Registry Pipeline"
        P2A[2.1 GHA Container Build Workflow] --> P2B[2.2 GHCR Registry Integration]
        P2B --> P2C[2.3 SA Pull Authentication]
    end

    subgraph "Phase 3: VM Runtime & Systemd Daemon Orchestration"
        P3A[3.1 GCE Provisioning & startup.sh] --> P3B[3.2 Systemd Persistent Disk Mount]
        P3B --> P3C[3.3 Secret Manager Fetching & env.list]
        P3C --> P3D[3.4 Container Daemon Registration]
        P3D --> P3E[3.5 Disruption & Reboot Recovery Test]
    end

    subgraph "Phase 4: Security, Operations & E2E Validation"
        P4A[4.1 Telegram Messaging E2E Test] --> P4B[4.2 ALLOWED_USER_IDS Access Control]
        P4B --> P4C[4.3 Automated Daily Disk Snapshots]
        P4C --> P4D[4.4 Observability, Journalctl & Runbooks]
    end

    P1D --> P2A
    P2C --> P3A
    P3E --> P4A
```

---

## Functional Phases Breakdown

### 📍 Phase 1: Foundation & GitOps IaC Pipeline
- **Milestone Goal**: Fully automated `terraform plan` and `terraform apply` pipeline executing via `abcxyz/guardian` and Workload Identity Federation (WIF).
- **Key Deliverables**:
  - GCP Service APIs, GCS state bucket, and `terraform-deployer` SA provisioned.
  - Keyless WIF Pool and OIDC Provider linked to GitHub Actions.
  - Terraform core configuration (`main.tf`, `variables.tf`, `outputs.tf`, `iam.tf`, `secret_manager.tf`).
  - GitHub Actions Guardian workflows (`terraform-plan.yml` and `terraform-apply.yml`).
  - Clean initial `terraform apply` verification using fallback container image.

### 📍 Phase 2: Container Build & Image Management Pipeline
- **Milestone Goal**: Immutable Docker container image compiled daily and on-demand, published to GitHub Container Registry (GHCR).
- **Key Deliverables**:
  - GitHub Actions workflow (`.github/workflows/build-container.yml`) for building image from `NanoGemClaw` source repository.
  - Package publication to GHCR with `latest` and commit SHA tags.
  - Registry access control verification permitting Compute Engine runtime service account image pulls.

### 📍 Phase 3: VM Runtime, Persistent Mount & Systemd Daemon Orchestration
- **Milestone Goal**: Ephemeral Compute Engine instance running containerized daemon bound to 20GB persistent disk.
- **Key Deliverables**:
  - Automated `startup.sh` script handling disk formatting, systemd mount registration (`opt-nanoclaw-data.mount`), and GCP Secret Manager fetching.
  - Production systemd container daemon (`nanoclaw-container.service`) with `Requires=opt-nanoclaw-data.mount`.
  - Disruption and reboot recovery test verifying zero data loss on SQLite database state across VM restarts.

### 📍 Phase 4: Operations, Security & End-to-End Validation
- **Milestone Goal**: Production-ready autonomous personal agent with zero-trust security and automated backup policies.
- **Key Deliverables**:
  - Messaging gateway verification (`/start` and `/status` bot command responses).
  - Security validation of `ALLOWED_USER_IDS` authorization enforcement.
  - GCP Resource Policy configuring automated daily snapshots of persistent data disk with 14-day retention.
  - Host logging (`journalctl`), system monitoring, and operational documentation.
