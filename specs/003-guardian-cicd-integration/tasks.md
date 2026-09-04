# Tasks: Guardian CI/CD Workflows & Policy Integration

**Input**: Design documents from `/specs/003-guardian-cicd-integration/`  
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`  

## Organization

Tasks are organized into Setup, User Story, and Polish phases to ensure incremental delivery and independent testability.

---

## Phase 1: Setup (Workflow Structure)

**Purpose**: Workflow directory layout preparation

- [x] T001 Verify and initialize `.github/workflows/` directory structure

---

## Phase 2: User Story 1 - Automated Plan Review on Pull Requests via Guardian (Priority: P1) 🎯 MVP

**Goal**: Implement `.github/workflows/terraform-plan.yml` to trigger Guardian plan reviews on PRs touching Terraform or workflow definitions.

**Independent Test**: Trigger workflow on PR and verify WIF auth, Guardian setup, and `guardian entrypoints plan` execution steps.

### Implementation for User Story 1

- [x] T002 [US1] Create `.github/workflows/terraform-plan.yml` with PR event triggers (`terraform/**`, `.github/workflows/**`) and required OIDC permissions (`id-token: write`, `contents: read`, `pull-requests: write`)
- [x] T003 [US1] Configure `google-github-actions/auth@v2`, `abcxyz/guardian/actions/setup@v1`, dynamic `-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"`, and `guardian entrypoints plan` step

---

## Phase 3: User Story 2 - Automated Apply Execution on Merge to Main via Guardian (Priority: P2)

**Goal**: Implement `.github/workflows/terraform-apply.yml` to execute Guardian apply on `main` branch merges.

**Independent Test**: Merge PR to `main` and verify Guardian apply execution log.

### Implementation for User Story 3

- [x] T004 [US2] Create `.github/workflows/terraform-apply.yml` with push triggers for `main` branch (`terraform/**`, `.github/workflows/**`) and required OIDC permissions (`id-token: write`, `contents: read`)
- [x] T005 [US2] Configure `google-github-actions/auth@v2`, `abcxyz/guardian/actions/setup@v1`, dynamic `-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"`, and `guardian entrypoints apply` step

---

## Phase 4: User Story 3 - Parameterized GitHub Secrets & Variables Injection (Priority: P3)

**Goal**: Dynamic parameter binding for all Terraform environment variables from GitHub repository settings.

**Independent Test**: Audit `.github/workflows/*.yml` for zero hardcoded secrets or infrastructure identifiers.

### Implementation for User Story 3

- [x] T006 [US3] Ensure all `TF_VAR_*` environment variables (`TF_VAR_project_id`, `TF_VAR_region`, `TF_VAR_zone`, `TF_VAR_allowed_user_ids`, `TF_VAR_gemini_api_key`, `TF_VAR_telegram_bot_token`) derive strictly from `vars.*` and `secrets.*`

---

## Phase 5: Polish & Validation

**Purpose**: Format validation, HCL verification, and documentation check

- [x] T007 Run `terraform validate` and `terraform fmt` across `terraform/`
- [x] T008 Validate YAML syntax and update `docs/quickstart.md` with CI/CD execution notes
