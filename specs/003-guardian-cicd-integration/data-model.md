# Data Model & Workflow Interfaces: Guardian CI/CD Integration

## Key Entities & Configuration Schema

### 1. GitHub Actions Workflow: `terraform-plan.yml`
- **Trigger**: `pull_request` targeting `main` with paths `terraform/**` or `.github/workflows/terraform-*.yml`.
- **Permissions**: `id-token: write`, `contents: read`, `pull-requests: write`.
- **Environment Variables**:
  - `WORKLOAD_IDENTITY_PROVIDER`: `${{ vars.GCP_WIF_PROVIDER }}`
  - `SERVICE_ACCOUNT`: `${{ vars.GCP_WIF_SERVICE_ACCOUNT }}`
  - `TF_VAR_project_id`: `${{ vars.GCP_PROJECT_ID }}`
  - `TF_VAR_region`: `${{ vars.GCP_REGION }}`
  - `TF_VAR_zone`: `${{ vars.GCP_ZONE }}`
  - `TF_VAR_allowed_user_ids`: `${{ vars.ALLOWED_USER_IDS }}`
  - `TF_VAR_gemini_api_key`: `${{ secrets.GEMINI_API_KEY }}`
  - `TF_VAR_telegram_bot_token`: `${{ secrets.TELEGRAM_BOT_TOKEN }}`
- **Execution Steps**:
  1. Checkout repository code.
  2. GCP WIF Authentication (`google-github-actions/auth@v2`).
  3. Setup Terraform (`hashicorp/setup-terraform@v3` with `1.5.7`) and Guardian CLI (`abcxyz/pkg/actions/setup-binary@v1`).
  4. Run `guardian entrypoints plan` with `-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"`.

### 2. GitHub Actions Workflow: `terraform-apply.yml`
- **Trigger**: `push` to `main` branch modifying `terraform/**` or `.github/workflows/terraform-*.yml`.
- **Permissions**: `id-token: write`, `contents: read`.
- **Environment Variables**:
  - Same environment parameter bindings as `terraform-plan.yml`.
- **Execution Steps**:
  1. Checkout repository code.
  2. GCP WIF Authentication (`google-github-actions/auth@v2`).
  3. Setup Terraform (`hashicorp/setup-terraform@v3` with `1.5.7`) and Guardian CLI (`abcxyz/pkg/actions/setup-binary@v1`).
  4. Run `guardian entrypoints apply` with `-backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"`.

### 3. Guardian Configuration File (`.guardianrc` or workflow CLI flags)
- Working Directory: `terraform`
- Terraform Version: `1.5.7`
