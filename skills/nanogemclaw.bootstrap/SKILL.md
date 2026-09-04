---
name: nanogemclaw.bootstrap
description: Automated end-to-end setup of GCP infrastructure, Workload Identity Federation (WIF), and GitHub repo secrets/variables for NanoGemClawTF.
---

# `nanogemclaw.bootstrap`

Automate GCP bootstrapping, Workload Identity Federation (WIF) setup, and GitHub repository configuration for **NanoGemClawTF**.

---

## 📋 User Prerequisites & Setup Instructions

Before running the automated steps, perform the following setup steps to gather the required bot credentials and keys:

### 1. Telegram Bot Token (`TELEGRAM_BOT_TOKEN`)
1. Open Telegram and search for [@BotFather](https://t.me/BotFather).
2. Send `/newbot` and follow the prompts to choose a name and username for your bot.
3. Copy the HTTP API Bot Token provided by BotFather (format: `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`).

### 2. Telegram Allowed User ID (`ALLOWED_USER_IDS`)
1. Open Telegram and search for [@userinfobot](https://t.me/userinfobot).
2. Send `/start` or any text message.
3. Copy your numeric User ID (e.g., `123456789`).

### 3. Gemini API Key (`GEMINI_API_KEY`)
1. Go to [Google AI Studio API Keys](https://aistudio.google.com/app/apikey).
2. Click **Create API key** and copy the generated key string.

---

## 💡 Interactive Information Gathering

Prompt the user for any missing parameters, offering smart defaults:

- **`GCP_PROJECT_ID`**: Detect using `gcloud config get-value project`. If empty, prompt user.
- **`GITHUB_REPO`**: Detect using `git remote get-url origin` (parsed as `owner/repo`). If empty, prompt user.
- **`GCP_REGION`**: Default to `us-central1` unless specified otherwise by user.
- **`GCP_ZONE`**: Default to `us-central1-a` unless specified otherwise by user.
- **`GCP_TF_STATE_BUCKET`**: Default to `${GCP_PROJECT_ID}-nanoclaw-tfstate`.
- **`TELEGRAM_BOT_TOKEN`**: Request from user (using instructions above).
- **`ALLOWED_USER_IDS`**: Request from user (using instructions above).
- **`GEMINI_API_KEY`**: Request from user (using instructions above).

---

## 🛠️ Execution Workflow

### Step 1: GCP Infrastructure & WIF Provisioning

Execute the following `gcloud` commands sequentially on behalf of the user:

```bash
# Set project context
gcloud config set project $GCP_PROJECT_ID

# 1. Enable Required GCP APIs
gcloud services enable \
  compute.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  storage.googleapis.com --project=$GCP_PROJECT_ID

# 2. Create Storage Bucket for Terraform Remote State
gcloud storage buckets create gs://${GCP_TF_STATE_BUCKET} --location=${GCP_REGION} --project=$GCP_PROJECT_ID

# 3. Create Service Account for Terraform Deployer
gcloud iam service-accounts create terraform-deployer \
  --display-name="Terraform Deployer SA for GitHub Actions" \
  --project=$GCP_PROJECT_ID

# Grant Roles to Service Account
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

# 4. Configure Workload Identity Federation (WIF)
gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --project=$GCP_PROJECT_ID

gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --project=$GCP_PROJECT_ID

# Allow GitHub Actions OIDC impersonation
PROJECT_NUMBER=$(gcloud projects describe $GCP_PROJECT_ID --format="value(projectNumber)")

gcloud iam service-accounts add-iam-policy-binding \
  "terraform-deployer@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}" \
  --project=$GCP_PROJECT_ID
```

Calculate WIF outputs:
```bash
GCP_WIF_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
GCP_SERVICE_ACCOUNT="terraform-deployer@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
```

---

### Step 2: Configure GitHub Repository Secrets & Variables

Use GitHub MCP tools or `gh` CLI commands to update repository configuration:

#### Set GitHub Repository Variables:
- `GCP_PROJECT_ID` -> `$GCP_PROJECT_ID`
- `GCP_REGION` -> `$GCP_REGION`
- `GCP_ZONE` -> `$GCP_ZONE`
- `GCP_TF_STATE_BUCKET` -> `$GCP_TF_STATE_BUCKET`
- `GCP_WIF_PROVIDER` -> `$GCP_WIF_PROVIDER`
- `GCP_SERVICE_ACCOUNT` -> `$GCP_SERVICE_ACCOUNT`
- `ALLOWED_USER_IDS` -> `$ALLOWED_USER_IDS`

Using `gh` CLI (or GitHub MCP server):
```bash
gh variable set GCP_PROJECT_ID --body "$GCP_PROJECT_ID" --repo "$GITHUB_REPO"
gh variable set GCP_REGION --body "$GCP_REGION" --repo "$GITHUB_REPO"
gh variable set GCP_ZONE --body "$GCP_ZONE" --repo "$GITHUB_REPO"
gh variable set GCP_TF_STATE_BUCKET --body "$GCP_TF_STATE_BUCKET" --repo "$GITHUB_REPO"
gh variable set GCP_WIF_PROVIDER --body "$GCP_WIF_PROVIDER" --repo "$GITHUB_REPO"
gh variable set GCP_SERVICE_ACCOUNT --body "$GCP_SERVICE_ACCOUNT" --repo "$GITHUB_REPO"
gh variable set ALLOWED_USER_IDS --body "$ALLOWED_USER_IDS" --repo "$GITHUB_REPO"
```

#### Set GitHub Repository Secrets:
- `GEMINI_API_KEY` -> `$GEMINI_API_KEY`
- `TELEGRAM_BOT_TOKEN` -> `$TELEGRAM_BOT_TOKEN`

Using `gh` CLI (or GitHub MCP server):
```bash
gh secret set GEMINI_API_KEY --body "$GEMINI_API_KEY" --repo "$GITHUB_REPO"
gh secret set TELEGRAM_BOT_TOKEN --body "$TELEGRAM_BOT_TOKEN" --repo "$GITHUB_REPO"
```

---

### Step 3: Verification & Validation

Execute the verification script to ensure all GCP resources and WIF policy bindings were successfully established:

```bash
./scripts/verify_wif_bootstrap.sh
```

---

### Step 4: Final Summary & Deployment Guidance

Upon completion, inform the user:
- All GCP prerequisites & WIF authentication configured.
- GitHub repository variables and secrets set.
- WIF binding verified.
- Instruct user to trigger deployment via GitHub Actions:
  ```bash
  git push origin main
  ```
