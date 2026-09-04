# Research: Guardian CI/CD Workflows & Policy Integration

## Decision 1: Use `abcxyz/guardian` for GitHub Actions Terraform Governance
- **Decision**: Integrate `abcxyz/guardian/actions/setup@v1` with Terraform `1.5.8` in GitHub Actions for PR plan reviews and `main` apply execution.
- **Rationale**: `abcxyz/guardian` provides automated plan commenting on PRs, policy enforcement, secure execution in GCP contexts, and declarative apply workflows on merge.
- **Alternatives Considered**: 
  - Standard HashiCorp `setup-terraform` + raw `terraform plan/apply` shell steps: Lacks built-in PR plan commenting, Guardian security governance policy checks, and structured entrypoint management.
  - Atlantis: Requires a long-running server instance or cluster, increasing monthly operational cost and baseline complexity.

## Decision 2: Keyless OIDC Authentication with `google-github-actions/auth@v2`
- **Decision**: Authenticate all GitHub Actions workflows to GCP using `google-github-actions/auth@v2` configured with Workload Identity Federation.
- **Rationale**: Complies with Constitution Principle 2 (Zero-Trust Security & Secret Isolation). No long-lived service account keys are created or stored.
- **Alternatives Considered**: Service Account JSON Keys in GitHub Secrets (Violates Constitution Principle 2).

## Decision 3: Dynamic GCS Backend Configuration Injection
- **Decision**: Inject backend state bucket dynamically at runtime using `-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"` during `guardian entrypoints plan` and `guardian entrypoints apply`.
- **Rationale**: Allows `backend.tf` to remain completely free of hardcoded project or bucket names, fulfilling Constitution Principle 3 (100% public forkability and zero private leakage).
- **Alternatives Considered**: Hardcoded bucket name in HCL (Violates Principle 3).

## Decision 4: Environment Variable Binding for Terraform Parameters
- **Decision**: Map GitHub Repository Variables (`vars.*`) to non-sensitive `TF_VAR_*` variables and GitHub Secrets (`secrets.*`) to sensitive `TF_VAR_*` variables (`TF_VAR_gemini_api_key`, `TF_VAR_telegram_bot_token`).
- **Rationale**: Ensures clear separation of public repository defaults vs secret environment variables without altering HCL code across forks.
