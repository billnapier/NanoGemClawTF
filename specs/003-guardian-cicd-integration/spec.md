# Feature Specification: Guardian CI/CD Workflows & Policy Integration

**Feature Branch**: `003-guardian-cicd-integration`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 1.3 of NanoGemClawTF Roadmap: GitHub Actions workflows (`terraform-plan.yml` and `terraform-apply.yml`) using `abcxyz/guardian`, keyless WIF authentication, dynamic GCS state injection, and parameter binding.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated Plan Review on Pull Requests via Guardian (Priority: P1)

As a Developer, I want GitHub Actions to automatically run `guardian entrypoints plan` whenever a pull request modifying `terraform/**` is opened or updated, so that infrastructure diffs and security policy checks are posted directly to the PR for review before merging.

**Why this priority**: Enforces GitOps governance, drift detection, and peer review prior to changing live infrastructure (Constitution Principle 1).

**Independent Test**: Can be tested independently by opening a test PR with a minor Terraform variable change and verifying that Guardian posts a formatted plan output comment on the PR.

**Acceptance Scenarios**:

1. **Given** a pull request targeting `main` with changes in `terraform/**`, **When** the PR is opened or synchronized, **Then** `.github/workflows/terraform-plan.yml` triggers, authenticates via WIF, runs `guardian entrypoints plan`, and comments the plan diff on the PR.
2. **Given** a pull request with invalid HCL syntax or policy violations, **When** Guardian executes `plan`, **Then** the workflow fails with detailed diagnostics and prevents PR merging.

---

### User Story 2 - Automated Apply Execution on Merge to Main via Guardian (Priority: P2)

As a Lead Maintainer, I want GitHub Actions to automatically run `guardian entrypoints apply` when a pull request is merged into `main`, so that infrastructure changes are applied deterministically to GCP without manual console interventions.

**Why this priority**: Guarantees declarative apply execution exclusively through verified CI/CD (Constitution Principle 1).

**Independent Test**: Can be tested independently by merging a PR into `main` and inspecting the GitHub Actions execution log for `guardian entrypoints apply`.

**Acceptance Scenarios**:

1. **Given** a merged commit on `main` touching `terraform/**`, **When** `.github/workflows/terraform-apply.yml` triggers, **Then** it authenticates via WIF, injects dynamic backend state config (`-backend-config="bucket=${vars.GCP_TF_STATE_BUCKET}"`), and executes `guardian entrypoints apply`.
2. **Given** an unsuccessful apply due to GCP API quota or permission issues, **When** apply fails, **Then** Guardian logs the exact error and sends failure notifications.

---

### User Story 3 - Parameterized GitHub Secrets & Variables Injection (Priority: P3)

As a Security Officer, I want Terraform execution variables (`TF_VAR_project_id`, `TF_VAR_region`, `TF_VAR_gemini_api_key`, etc.) injected dynamically into Guardian workflows from GitHub Repository Variables (`vars.*`) and Secrets (`secrets.*`), so that zero private variables or credentials exist in workflow code.

**Why this priority**: Protects repository maintainers and guarantees public forkability (Constitution Principle 3).

**Independent Test**: Can be tested independently by reviewing workflow YAML definitions for hardcoded values and running workflow dry-runs with test repository variables.

**Acceptance Scenarios**:

1. **Given** Guardian workflow steps, **When** environment variables are evaluated, **Then** non-sensitive values derive from `vars.*` and sensitive values derive from `secrets.*`.

---

### Edge Cases

- What happens if `vars.GCP_TF_STATE_BUCKET` or `vars.GCP_WIF_PROVIDER` is missing in repository configuration?
  - Workflow step validation fails fast with a clear diagnostic message directing the operator to setup repository parameters as documented in `docs/quickstart.md`.
- How does system handle concurrent PR merges attempting simultaneous Terraform applies?
  - GCS state locking automatically queues or fails concurrent apply executions to prevent state race conditions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide `.github/workflows/terraform-plan.yml` for pull request plan reviews using `abcxyz/guardian`.
- **FR-002**: System MUST provide `.github/workflows/terraform-apply.yml` for `main` branch applies using `abcxyz/guardian`.
- **FR-003**: Workflows MUST use `google-github-actions/auth@v2` with Workload Identity Federation (`workload_identity_provider` and `service_account`).
- **FR-004**: Workflows MUST setup `abcxyz/guardian` action setup (`abcxyz/guardian/actions/setup@v1`) with Terraform `>= 1.5.0`.
- **FR-005**: Workflows MUST dynamically inject backend configuration (`-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"`).
- **FR-006**: Workflows MUST pass all parameters (`TF_VAR_project_id`, `TF_VAR_region`, `TF_VAR_zone`, `TF_VAR_allowed_user_ids`, `TF_VAR_gemini_api_key`, `TF_VAR_telegram_bot_token`) from GitHub repository settings.

### Key Entities

- **Guardian Plan Workflow**: GitHub Actions workflow for pull request validation (`terraform-plan.yml`).
- **Guardian Apply Workflow**: GitHub Actions workflow for `main` branch deployment (`terraform-apply.yml`).
- **WIF Auth Step**: Keyless authentication action (`google-github-actions/auth@v2`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of pull requests modifying `terraform/**` automatically generate a Guardian plan comment within 3 minutes.
- **SC-002**: Merges to `main` complete `guardian entrypoints apply` successfully with zero manual terminal commands required.
- **SC-003**: Zero static credentials or private GCP identifiers exist in `.github/workflows/*.yml`.
