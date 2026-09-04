# Tasks: Core Infrastructure & Secret Manager Integration

**Input**: Design documents from `/specs/002-terraform-core-secrets/`  
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`  

## Organization

Tasks are organized into Setup, Foundational, and User Story phases to ensure incremental delivery and independent testability.

---

## Phase 1: Setup (Shared Infrastructure & Variables)

**Purpose**: Input variable definitions and startup script setup

- [x] T001 Update `terraform/variables.tf` to define runtime SA name, secret IDs, fallback container image (`alpine:latest`), VM machine type (`e2-small`), and persistent disk size (20GB)
- [x] T002 Create startup metadata script template in `scripts/startup.sh` handling persistent disk mounting and container runtime startup

---

## Phase 2: User Story 1 - Declarative GCP Secret Storage & IAM Access (Priority: P1) 🎯 MVP

**Goal**: Provision GCP Secret Manager secret containers, initial versions, and accessor IAM bindings for the runtime Service Account.

**Independent Test**: Verify secret container resources and IAM accessor member bindings in `terraform/secret_manager.tf` and `terraform/iam.tf`.

### Implementation for User Story 1

- [x] T003 [US1] Create runtime Service Account `nanoclaw-agent-runtime-sa` in `terraform/iam.tf`
- [x] T004 [US1] Declare Secret Manager secrets `gemini-api-key` and `telegram-bot-token` with optional version placeholders in `terraform/secret_manager.tf`
- [x] T005 [US1] Declare `google_secret_manager_secret_iam_member` bindings granting `roles/secretmanager.secretAccessor` to `nanoclaw-agent-runtime-sa` in `terraform/iam.tf`

**Checkpoint**: Secret Manager containers and IAM accessor policies declared.

---

## Phase 3: User Story 2 - Decoupled Persistent Data Disk & Compute Engine VM (Priority: P2)

**Goal**: Declare persistent 20GB disk with `prevent_destroy = true` and `e2-small` Compute Engine VM instance.

**Independent Test**: Verify `prevent_destroy = true` on `google_compute_disk.agent_data` and attached disk configuration in `terraform/main.tf`.

### Implementation for User Story 2

- [x] T006 [US2] Declare 20GB `pd-standard` persistent disk `nanoclaw-data-disk` with `prevent_destroy = true` in `terraform/main.tf`
- [x] T007 [US2] Declare `e2-small` Compute Engine instance `nanoclaw-gemini-agent` binding runtime SA and attaching persistent disk in `terraform/main.tf`

**Checkpoint**: Compute VM and decoupled persistent disk declared.

---

## Phase 4: User Story 3 - Decoupled Fallback Image Initialization (Priority: P3)

**Goal**: Render `startup.sh` template into VM metadata passing `var.container_image` fallback (`alpine:latest`).

**Independent Test**: Run `terraform plan` to verify startup metadata rendering.

### Implementation for User Story 3

- [x] T008 [US3] Inject template startup script metadata into `google_compute_instance.nanoclaw_vm` in `terraform/main.tf`
- [x] T009 [US3] Declare Terraform outputs in `terraform/outputs.tf` for runtime SA email, Secret IDs, VM instance name, and disk device name

**Checkpoint**: Startup script metadata and outputs ready.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Format validation, HCL verification, and static analysis

- [x] T010 Run `terraform fmt` and `terraform validate` across `terraform/`
- [x] T011 Verify zero plain-text secrets exist in codebase or Terraform files
