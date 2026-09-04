# NanoGemClawTF Deployment Quickstart 🚀

> [!IMPORTANT]
> **Synchronization Policy**: Per Constitution Principle 7, all manual operational steps (not provisioned via IaC) MUST be documented in this guide. This document (`docs/quickstart.md`) and the executable quickstart skill (`nanogemclaw.bootstrap`) MUST be kept strictly in sync at all times. Whenever either file is updated, the corresponding counterpart MUST be audited and updated simultaneously.

This step-by-step guide will walk you through setting up Google Cloud Platform (GCP), configuring GitHub Actions keyless authentication (Workload Identity Federation), and deploying your personal **NanoGemClaw** agent in under 10 minutes.

---

## 📋 Prerequisites

Before starting, ensure you have:
1. A **Google Cloud Platform (GCP)** account with billing enabled.
2. A **GCP Storage Bucket** for Terraform state management.
3. A **Google Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).
4. A **Telegram Bot Token** from [@BotFather](https://t.me/BotFather) (or Discord/Slack bot token).
5. Your personal **Telegram User ID** (get it via [@userinfobot](https://t.me/userinfobot)).
6. The `gcloud` CLI installed locally (optional, for initial GCP bootstrap).

---

## Step 1: Bootstrap GCP Prerequisites (One-Time Setup)

### Option A: Antigravity Skill Automation (Experimental) 🤖

If you are using the **Antigravity AI Coding Assistant**, you can run our experimental automated setup skill:

```text
/nanogemclaw.bootstrap
```

The agent will guide you through acquiring required tokens (Telegram Bot Token, User ID, Gemini API Key), execute all GCP `gcloud` setup steps, and automatically configure GitHub secrets and variables via GitHub MCP/CLI.

---

### Option B: Automated Shell Script Bootstrap

Set your environment variables and execute the single-command bootstrap script:

```bash
export GCP_PROJECT_ID="your-gcp-project-id"
export GITHUB_REPO="your-github-username/NanoGemClawTF"

./scripts/bootstrap_gcp_foundation.sh
```

To verify your bootstrap configuration non-destructively at any time:

```bash
./scripts/verify_wif_bootstrap.sh
```

---

### Option C: Manual Step-by-Step Setup

Set your target GCP Project ID in your terminal:

```bash
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID
```

### 1.1 Enable Required GCP Service APIs

```bash
gcloud services enable \
  compute.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  storage.googleapis.com
```

### 1.2 Create Terraform State Bucket

```bash
export BUCKET_NAME="${PROJECT_ID}-nanoclaw-tfstate"
gcloud storage buckets create gs://${BUCKET_NAME} --location=us-central1
```

### 1.3 Create Terraform Deployer Service Account

```bash
gcloud iam service-accounts create terraform-deployer \
  --display-name="Terraform Deployer SA for GitHub Actions"

# Grant Editor / Admin roles required for Compute, Secret Manager, and Storage
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/secretmanager.admin"
```

### 1.4 Configure Workload Identity Federation (WIF)

Replace `YOUR_GITHUB_ORG/YOUR_REPO` with your GitHub username and repository name:

```bash
export GITHUB_REPO="your-github-username/NanoGemClawTF"

# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Create OIDC Provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Allow GitHub Actions from your repo to impersonate the Terraform Deployer SA
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcloud iam service-accounts add-iam-policy-binding \
  "terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```

Get your **WIF Provider Resource String** for GitHub Actions:

```bash
echo "projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```

---

## Step 2: Configure GitHub Repository Secrets & Variables

In your forked GitHub repository, navigate to **Settings → Secrets and variables → Actions**.

### Add Variables (`Repository variables` tab)
| Variable Name | Description | Example |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `my-gemini-agent-prod` |
| `GCP_REGION` | GCP Compute Region | `us-central1` |
| `GCP_ZONE` | GCP Compute Zone | `us-central1-a` |
| `GCP_TF_STATE_BUCKET` | GCP Storage bucket created in Step 1.2 | `my-gemini-agent-prod-nanoclaw-tfstate` |
| `GCP_WIF_PROVIDER` | Output from Step 1.4 | `projects/1234.../providers/github-provider` |
| `GCP_SERVICE_ACCOUNT` | Terraform deployer service account email | `terraform-deployer@my-proj.iam.gserviceaccount.com` |
| `ALLOWED_USER_IDS` | Comma-separated allowed messaging user IDs | `123456789` |

### Add Secrets (`Repository secrets` tab)
| Secret Name | Description |
| :--- | :--- |
| `GEMINI_API_KEY` | Your Gemini API Key from Google AI Studio |
| `TELEGRAM_BOT_TOKEN` | Your Telegram Bot Token from `@BotFather` |

---

## Step 3: Deploy via GitHub Actions

1. Push your changes to `main` (or create a Pull Request to run `terraform plan` via `abcxyz/guardian`).
2. Navigate to the **Actions** tab in GitHub to watch the `Build Container Image` and `Terraform Apply` workflows execute.
3. Upon completion (~2-3 minutes), GCP Compute Engine will provision the `e2-small` VM, attach the 20GB persistent data disk via systemd mount unit, retrieve secrets, and launch the containerized NanoGemClaw service.

---

## Step 4: Verify Deployment & Connect to Bot

1. Open **Telegram** (or your chosen messaging app) and open your bot's chat.
2. Send the command:
   ```text
   /start
   ```
   or
   ```text
   /status
   ```
3. The bot will respond with its operational readiness status:
   > 🚀 **NanoGemClaw is online!**  
   > **Model**: Google Gemini  
   > **Runtime**: Sandboxed Container Execution  
   > **Status**: Ready for prompts and tasks.

---

## 🛠️ Operational Commands & Logs

If you ever need to inspect VM logs or debug host startup:

```bash
# SSH into VM instance
gcloud compute ssh nanoclaw-gemini-agent --zone=us-central1-a

# Check systemd persistent data mount status
sudo systemctl status opt-nanoclaw-data.mount

# Check systemd container daemon status
sudo systemctl status nanoclaw-container.service

# View live container daemon logs
sudo journalctl -u nanoclaw-container.service -f
```
