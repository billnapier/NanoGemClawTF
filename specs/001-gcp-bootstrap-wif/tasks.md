# Tasks: GCP Foundation & Workload Identity Federation Setup

**Input**: Design documents from `/specs/001-gcp-bootstrap-wif/`  
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`  

## Organization

Tasks are organized into Setup, Foundational, and User Story phases to ensure incremental delivery and independent testability.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Repository structure initialization

- [x] T001 Initialize directory structure (`terraform/` and `scripts/`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Base Terraform configuration structure required before feature definition

- [x] T002 Create `terraform/variables.tf` defining project, region, bucket, and repo input variables
- [x] T003 Create `terraform/main.tf` configuring HashiCorp Google provider (~> 5.0) and backend structure
- [x] T004 Create `terraform/outputs.tf` defining Terraform outputs for WIF provider resource name and deployer SA email

**Checkpoint**: Foundation ready - Terraform base files exist.

---

## Phase 3: User Story 1 - Keyless GitHub Actions Authentication via WIF (Priority: P1) 🎯 MVP

**Goal**: Enable WIF pool, OIDC provider, and `terraform-deployer` SA impersonation for GitHub Actions.

**Independent Test**: Execute `scripts/verify_wif_bootstrap.sh` to check WIF pool and provider configuration.

### Implementation for User Story 1

- [x] T005 [US1] Create automated GCP bootstrap script in `scripts/bootstrap_gcp_foundation.sh`
- [x] T006 [US1] Create non-destructive GCP validation script in `scripts/verify_wif_bootstrap.sh`
- [x] T007 [US1] Set executable permissions on `scripts/bootstrap_gcp_foundation.sh` and `scripts/verify_wif_bootstrap.sh`

**Checkpoint**: WIF pool/provider bootstrap automation and verification scripts are functional.

---

## Phase 4: User Story 2 - Automated GCS Terraform State Storage (Priority: P2)

**Goal**: Provision and configure versioned, locked GCS state storage bucket.

**Independent Test**: Verify bucket status and properties via `scripts/verify_wif_bootstrap.sh`.

### Implementation for User Story 2

- [x] T008 [US2] Ensure `scripts/bootstrap_gcp_foundation.sh` and `scripts/verify_wif_bootstrap.sh` handle bucket creation, uniform access, and versioning options

**Checkpoint**: GCS state bucket configuration verified.

---

## Phase 5: User Story 3 - Least-Privilege Terraform Deployer Service Account (Priority: P3)

**Goal**: Configure `terraform-deployer` SA with required roles and WIF principal mapping.

**Independent Test**: Verify IAM bindings via `scripts/verify_wif_bootstrap.sh`.

### Implementation for User Story 3

- [x] T009 [US3] Add IAM policy bindings for `terraform-deployer` SA in `scripts/bootstrap_gcp_foundation.sh` and assertions in `scripts/verify_wif_bootstrap.sh`

**Checkpoint**: Deployer SA roles and WIF bindings verified.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and static analysis verification

- [x] T010 [P] Update `docs/quickstart.md` to reference `scripts/bootstrap_gcp_foundation.sh` and `scripts/verify_wif_bootstrap.sh`
- [x] T011 Run `terraform fmt` and `terraform validate` to verify HCL correctness
