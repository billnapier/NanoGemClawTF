# Feature Specification: Initial Infrastructure Provisioning & Fallback Verification

**Feature Branch**: `004-phase1-validation-apply`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 1.4 of NanoGemClawTF Roadmap: Secret bootstrapping verification in GitHub Repository Secrets, execution of Guardian pipeline for clean initial `terraform apply`, GCS remote state validation, and fallback container image provisioning.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative GitHub Repository Secret Bootstrapping (Priority: P1)

As a Repository Administrator, I want to populate initial placeholders or real values for `GEMINI_API_KEY` and `TELEGRAM_BOT_TOKEN` in GitHub Repository Secrets before triggering Phase 1 apply, so that GCP Secret Manager secret versions are provisioned cleanly by Terraform without pipeline failure.

**Why this priority**: Prevents Terraform resource provisioning errors due to empty or missing secret variables during initial apply (TPM Decision Q2).

**Independent Test**: Can be tested independently by populating repo secrets and running a pre-flight workflow check step to verify secret variable resolution.

**Acceptance Scenarios**:

1. **Given** GitHub Repository Secrets configured (`GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`), **When** Guardian runs `terraform apply`, **Then** Secret Manager resources in GCP are successfully populated with version 1 secret payloads.
2. **Given** missing repository secret inputs, **When** workflow pre-check runs, **Then** a descriptive failure message informs the operator of missing secret inputs.

---

### User Story 2 - Initial End-to-End Infrastructure Apply Verification (Priority: P2)

As a DevOps Engineer, I want the complete Phase 1 infrastructure (Secret Manager, Service Account, IAM bindings, Persistent Disk, Compute Engine instance) provisioned cleanly via Guardian on `main` merge using the fallback image (`alpine:latest`), so that Phase 1 milestone completion is verified end-to-end.

**Why this priority**: Confirms that all IaC components, IAM permissions, and pipeline triggers function harmoniously in production GCP.

**Independent Test**: Can be tested independently by querying GCP APIs (`gcloud compute instances describe nanoclaw-gemini-agent`, `gcloud secrets list`) after the pipeline run completes.

**Acceptance Scenarios**:

1. **Given** Phase 1 code merged to `main`, **When** `terraform-apply.yml` completes, **Then** GCP resources (VM instance `nanoclaw-gemini-agent`, disk `nanoclaw-data-disk`, SA `nanoclaw-agent-runtime-sa`, and secrets) show status `RUNNING` or `READY`.
2. **Given** state storage in GCS, **When** checked, **Then** `default.tfstate` exists in `vars.GCP_TF_STATE_BUCKET` with valid state resource entries.

---

### User Story 3 - Host Startup & Fallback Image Verification (Priority: P3)

As a Maintainer, I want to verify that the provisioned Compute Engine VM executes `startup.sh`, registers storage mounts, and pulls the fallback container image (`alpine:latest`), so that VM host initialization logic is validated prior to Phase 2 application container builds.

**Why this priority**: Validates host startup script execution without blocking on custom container image compilation.

**Independent Test**: Can be tested independently by inspecting VM serial port logs (`gcloud compute instances get-serial-port-output nanoclaw-gemini-agent`) for successful `startup.sh` completion.

**Acceptance Scenarios**:

1. **Given** the provisioned Compute Engine instance, **When** VM serial console logs are audited, **Then** `startup.sh` output indicates successful systemd mount registration and execution without error.

---

### Edge Cases

- What happens if the GCP project quota for Persistent Disks or Compute Engine CPUs is exceeded?
  - Terraform apply fails with clear GCP quota error details in Guardian pipeline output; operator increases project quota via GCP Console.
- How does system handle re-running initial apply when secrets already exist?
  - Terraform idempotently manages secret versions, updating or retaining existing versions without error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST require GitHub Repository Secrets (`GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`) and Repository Variables (`GCP_PROJECT_ID`, `GCP_REGION`, `GCP_ZONE`, `GCP_WIF_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `GCP_TF_STATE_BUCKET`, `ALLOWED_USER_IDS`) prior to initial apply execution.
- **FR-002**: System MUST execute a clean initial `terraform apply` via Guardian workflow on `main`.
- **FR-003**: System MUST verify creation and proper configuration of all GCP resources declared in Phase 1 IaC.
- **FR-004**: System MUST verify lockable, versioned state preservation in GCS state bucket.
- **FR-005**: System MUST verify Compute Engine VM instance initialization with fallback container image (`alpine:latest`).

### Key Entities

- **Provisioned Infrastructure Stack**: GCP VM (`nanoclaw-gemini-agent`), Data Disk (`nanoclaw-data-disk`), Secrets, SA, and IAM bindings.
- **GCS Remote State**: Persistent state object residing in `vars.GCP_TF_STATE_BUCKET`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Phase 1 GCP infrastructure resources provisioned cleanly via Guardian pipeline with zero manual GCP Console edits.
- **SC-002**: Compute Engine VM serial console logs confirm 0 errors during `startup.sh` execution.
- **SC-003**: GCS remote state file matches expected resource graph and enables subsequent drift detection.
