# Feature Specification: GCP Foundation & Workload Identity Federation Setup

**Feature Branch**: `001-gcp-bootstrap-wif`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 1.1 of NanoGemClawTF Roadmap: GCP Service APIs, GCS state bucket, terraform-deployer Service Account, and keyless Workload Identity Federation (WIF) setup.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keyless GitHub Actions Authentication via WIF (Priority: P1)

As a DevOps Engineer / Maintainer, I want GitHub Actions to authenticate to Google Cloud Platform using Workload Identity Federation (WIF) without using long-lived JSON service account key files, so that pipeline authentication is secure, keyless, and automatically tokenized.

**Why this priority**: Long-lived service account keys present severe security leak risks. WIF is the zero-trust foundational requirement for all subsequent CI/CD pipelines (Constitution Principle 2).

**Independent Test**: Can be independently verified by executing a lightweight `gcloud` OIDC token exchange test from a GitHub Actions workflow step against the provisioned WIF pool/provider.

**Acceptance Scenarios**:

1. **Given** a GitHub Actions workflow running in `billnapier/NanoGemClawTF`, **When** the workflow exchanges a GitHub OIDC token with the GCP WIF provider, **Then** a short-lived GCP authentication token is returned for the `terraform-deployer` service account without using any static JSON keys.
2. **Given** an unauthorized GitHub repository or non-matching repository context, **When** it attempts to exchange tokens with the GCP WIF provider, **Then** authentication is strictly denied by GCP IAM policy.

---

### User Story 2 - Automated GCS Terraform State Storage (Priority: P2)

As a Maintainer, I want a dedicated, versioned GCP Cloud Storage (GCS) bucket configured for Terraform state, so that state files are securely locked, encrypted, and preserved across pipeline runs.

**Why this priority**: Remote state storage with locking is required before Terraform can execute non-interactively in CI/CD pipelines.

**Independent Test**: Can be tested independently by running `gcloud storage buckets describe` on the configured bucket to verify uniform bucket-level access, object versioning, and encryption.

**Acceptance Scenarios**:

1. **Given** the GCP environment, **When** the GCS bucket is provisioned, **Then** object versioning and uniform bucket-level access are enabled.
2. **Given** a concurrent Terraform operation, **When** a second operation attempts to modify state, **Then** state locking prevents state corruption.

---

### User Story 3 - Least-Privilege Terraform Deployer Service Account (Priority: P3)

As a Cloud Administrator, I want a dedicated `terraform-deployer` service account with strictly scoped IAM permissions needed for provisioning Compute Engine, Secret Manager, and IAM bindings, so that pipeline operations follow least-privilege security principles.

**Why this priority**: Ensures the deployer identity has the exact permissions required to provision Phase 1-4 resources without granting excessive organization-wide roles.

**Independent Test**: Can be tested independently by listing IAM role bindings assigned to `terraform-deployer@<project_id>.iam.gserviceaccount.com`.

**Acceptance Scenarios**:

1. **Given** the `terraform-deployer` service account, **When** IAM roles are assigned, **Then** it possesses roles for Compute Admin, Secret Manager Admin, and IAM Service Account User within the targeted GCP project.

---

### Edge Cases

- What happens if the GCS state bucket name is already globally taken in GCP?
  - The state bucket name MUST be parameterized via GitHub Actions repository variable (`vars.GCP_TF_STATE_BUCKET`) to guarantee uniqueness per project deployment (Constitution Principle 3).
- How does system handle WIF provider token expiration during long-running terraform plans?
  - WIF tokens automatically default to 1-hour expiration, which is more than sufficient for Terraform operations; job execution will request fresh tokens per workflow run.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST enable required GCP Service APIs (`compute.googleapis.com`, `secretmanager.googleapis.com`, `iam.googleapis.com`, `cloudresourcemanager.googleapis.com`, `iamcredentials.googleapis.com`, `sts.googleapis.com`).
- **FR-002**: System MUST provision a versioned GCS bucket for Terraform remote state locking and storage.
- **FR-003**: System MUST create a dedicated `terraform-deployer` GCP Service Account for CI/CD pipeline execution.
- **FR-004**: System MUST provision a GCP Workload Identity Pool and Provider bound strictly to the GitHub repository identity.
- **FR-005**: All bootstrap operations and WIF parameters MUST be documented in `docs/quickstart.md` and executable via the `quickstart` Antigravity skill (Constitution Principle 7).

### Key Entities

- **Workload Identity Pool**: Logical container for GitHub Actions OIDC identity trust relationship in GCP.
- **Workload Identity Provider**: Provider entity linking GitHub's `token.actions.githubusercontent.com` issuer to GCP IAM.
- **Deployer Service Account**: GCP Service Account (`terraform-deployer`) impersonated by GitHub Actions during pipeline runs.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: WIF token exchange completes successfully in under 5 seconds during GitHub Actions workflow execution.
- **SC-002**: Zero long-lived JSON service account keys exist or are generated during the bootstrap process.
- **SC-003**: GCS state bucket has 100% object versioning and uniform bucket-level access enabled.
