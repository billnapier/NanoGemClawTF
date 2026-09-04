# Tasks: Initial Infrastructure Provisioning & Fallback Verification

**Input**: Design documents from `/specs/004-phase1-validation-apply/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup & Pre-Flight Infrastructure

- [x] T001 Verify feature branch `004-phase1-validation-apply` is up to date with `origin/main`
- [x] T002 Verify design artifacts in `specs/004-phase1-validation-apply/` (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`)

---

## Phase 2: User Story 1 - Declarative GitHub Repository Secret Bootstrapping (Priority: P1)

**Goal**: Ensure repository secrets and pre-flight validation logic prevent empty secret variables during apply.

- [x] T003 [US1] Audit `terraform/variables.tf` and `terraform/secrets.tf` to ensure `gemini_api_key` and `telegram_bot_token` variables have required sensitive parameters.
- [x] T004 [US1] Verify pre-flight validation logic in `scripts/verify_wif_bootstrap.sh` checks for Secret Manager access and repository variable presence.

---

## Phase 3: User Story 2 - Initial End-to-End Infrastructure Apply Verification (Priority: P2)

**Goal**: Provision complete Phase 1 infrastructure via Guardian pipeline and verify GCP resource status and GCS state storage.

- [x] T005 [US2] Create non-destructive Phase 1 validation script `scripts/verify_phase1_deployment.sh` to audit VM instance status, disk attachment, and Secret Manager versions.
- [x] T006 [US2] Add execution permissions (`chmod +x`) to `scripts/verify_phase1_deployment.sh`.
- [x] T007 [US2] Validate shell syntax of `scripts/verify_phase1_deployment.sh` via `bash -n`.

---

## Phase 4: User Story 3 - Host Startup & Fallback Image Verification (Priority: P3)

**Goal**: Verify serial port logging audit function in `scripts/verify_phase1_deployment.sh` for `startup.sh` execution and fallback container image (`alpine:latest`).

- [x] T008 [US3] Add VM serial port log auditing logic to `scripts/verify_phase1_deployment.sh` to check for clean systemd startup and mount registration.

---

## Phase 5: Polish & Cross-Cutting Verification

- [x] T009 [P] Validate HCL files via `terraform validate` and `terraform fmt -check` in `terraform/` directory.
- [x] T010 [P] Execute `scripts/verify_phase1_deployment.sh` syntax and sanity checks.
- [x] T011 Update project status in `.specify/STATUS.md` to reflect 100% completion of feature 004.
