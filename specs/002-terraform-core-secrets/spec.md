# Feature Specification: Terraform Core Infrastructure & Secret Manager Integration

**Feature Branch**: `002-terraform-core-secrets`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 1.2 of NanoGemClawTF Roadmap: Terraform core HCL configuration, least-privilege runtime SA, Secret Manager containers, Secret Manager IAM bindings, persistent disk, and Compute Engine VM module with fallback container support.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative GCP Secret Storage & IAM Access (Priority: P1)

As an Application Operator, I want Gemini API keys and Telegram bot tokens declared in GCP Secret Manager with automatic IAM accessor permissions granted to the runtime service account, so that credentials are protected and retrieved dynamically at runtime without exposing sensitive data in source code or VM metadata.

**Why this priority**: Zero-trust security and dynamic secret management are non-negotiable requirements (Constitution Principle 2).

**Independent Test**: Can be tested independently by creating test secret versions via Terraform and verifying that the runtime service account can read secret payloads using `gcloud secrets versions access` while unauthorized accounts are blocked.

**Acceptance Scenarios**:

1. **Given** secret variables provided via Terraform, **When** `terraform apply` executes, **Then** `gemini-api-key` and `telegram-bot-token` secrets and secret versions are created in GCP Secret Manager.
2. **Given** the `nanoclaw-agent-runtime-sa` service account, **When** secret IAM accessor bindings are applied, **Then** only this service account holds `roles/secretmanager.secretAccessor` on the created secrets.

---

### User Story 2 - Decoupled Persistent Data Disk & Compute Engine VM (Priority: P2)

As a Infrastructure Engineer, I want the agent persistent data storage to reside on a separate GCP Persistent Disk (`pd-standard`, 20GB) attached to an `e2-small` Compute Engine VM, so that agent state and databases persist across VM recreations and updates.

**Why this priority**: Decouples application state from disposable host infrastructure (Constitution Principle 4).

**Independent Test**: Can be tested independently by running `terraform plan` to confirm `google_compute_disk` lifecycle configuration includes `prevent_destroy = true` and `google_compute_instance` binds the disk device.

**Acceptance Scenarios**:

1. **Given** Terraform configuration, **When** the VM instance is declared, **Then** it references an attached disk `nanoclaw-data-disk` with `prevent_destroy = true`.
2. **Given** an infrastructure update or VM replacement, **When** the VM is recreated, **Then** the persistent data disk retains its identifier and data payload.

---

### User Story 3 - Decoupled Fallback Image Initialization (Priority: P3)

As a Developer, I want the Terraform Compute Engine module to accept a default container image variable (`TF_VAR_container_image`, defaulting to `alpine:latest`), so that Phase 1 infrastructure apply can complete and be validated independently before Phase 2 container build workflows are executed.

**Why this priority**: Decouples IaC pipeline validation from container registry build dependencies (TPM Decision Q1).

**Independent Test**: Can be tested independently by executing `terraform plan` with `var.container_image = "alpine:latest"` and verifying startup script metadata template rendering.

**Acceptance Scenarios**:

1. **Given** no custom GHCR container image tag passed to Terraform, **When** Terraform evaluates variables, **Then** `var.container_image` falls back to `alpine:latest`.
2. **Given** `startup.sh` rendered metadata, **When** inspected, **Then** container daemon configuration references the configured image variable cleanly.

---

### Edge Cases

- What happens if Gemini API key or Telegram bot token strings contain special characters or spaces?
  - Secret Manager payloads accept binary and sensitive string streams; Terraform secret version resources pass `secret_data` cleanly without string escaping distortion.
- How does system handle persistent disk destruction attempts during `terraform destroy`?
  - `lifecycle { prevent_destroy = true }` on `google_compute_disk.agent_data` explicitly blocks accidental disk deletion.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide declarative Terraform files (`main.tf`, `variables.tf`, `outputs.tf`, `iam.tf`, `secret_manager.tf`, `scripts/startup.sh`).
- **FR-002**: System MUST declare a dedicated runtime Service Account (`nanoclaw-agent-runtime-sa`) with least-privilege permissions.
- **FR-003**: System MUST declare GCP Secret Manager secret containers and versions for `gemini-api-key` and `telegram-bot-token`.
- **FR-004**: System MUST bind `roles/secretmanager.secretAccessor` for the runtime SA to the Secret Manager resources.
- **FR-005**: System MUST declare a 20GB `pd-standard` persistent compute disk (`nanoclaw-data-disk`) with `prevent_destroy = true`.
- **FR-006**: System MUST declare an `e2-small` Compute Engine instance (`nanoclaw-gemini-agent`) on Debian 12 attaching the persistent disk and injecting `startup.sh` template metadata.
- **FR-007**: System MUST default `var.container_image` to a fallback container image (`alpine:latest`) to decouple Phase 1 apply from Phase 2 container compilation.

### Key Entities

- **Runtime Agent SA**: `google_service_account.agent_sa` (`nanoclaw-agent-runtime-sa`).
- **Secret Manager Secrets**: `google_secret_manager_secret` for Gemini API key and Telegram bot token.
- **Agent Data Disk**: `google_compute_disk.agent_data` (20GB persistent disk).
- **Compute Instance**: `google_compute_instance.nanoclaw_vm` (`e2-small` host).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of infrastructure resources pass `terraform validate` and `terraform plan` without errors or warnings.
- **SC-002**: Zero secret values or hardcoded project IDs appear in Terraform source code files or git commits.
- **SC-003**: Compute Engine VM startup metadata correctly renders container image, allowed user IDs, and secret reference paths.
