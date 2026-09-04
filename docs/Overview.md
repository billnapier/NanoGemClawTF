# Design Doc: GitOps & Terraform Infrastructure for NanoClaw with Gemini on GCP

**Status:** Approved  
**Author:** Engineering  
**Last Updated:** August 2026  

---

## 1. Executive Summary & Objective

This design document establishes the infrastructure, security model, and automated GitOps deployment pipeline for hosting a low-overhead, autonomous personal agent harness based on the **NanoClaw** (or **NanoGemClaw**) architecture on Google Cloud Platform (GCP). The system utilizes **Google Gemini** for multimodal reasoning and function calling, while enforcing declarative Infrastructure-as-Code (IaC) via **Terraform** and continuous delivery via **GitHub Actions**.

The primary goal is to minimize idle daemon overhead, token consumption, and operational friction compared to heavy agent frameworks while providing state retention, sandboxed tool execution, and secure, keyless automation from GitHub.

---

## 2. Architectural Overview

The system architecture separates declarative infrastructure orchestration, CI/CD automation, VM runtime hosting, and agent execution layers:

| Layer | Component | Description & Role |
| :--- | :--- | :--- |
| **GitOps / CI/CD** | GitHub Actions + WIF | Executes automated `terraform plan` and `apply` workflows using keyless GCP Workload Identity Federation. |
| **Infrastructure** | Google Compute Engine (GCE) | Lightweight `e2-small` Debian 12 virtual machine hosting the agent host daemon and container engine. |
| **State Storage** | GCP Persistent Disk (Zonal) | Separate 20GB Persistent Disk mounted to `/opt/nanoclaw/data` retaining SQLite databases and file memory across VM recreations. |
| **Secrets Layer** | GCP Secret Manager | Stores Gemini API keys and messaging gateway tokens (Telegram, Discord, Slack) securely without committing secrets. |
| **Agent Harness** | NanoClaw / NanoGemClaw | Single-process Node.js host daemon that coordinates message channels and dispatches ephemeral tool execution containers. |
| **Model Inference** | Google Gemini API | Powers reasoning, context processing, fast-path routing, and structured function calling. |

---

## 3. Repository Layout & GitOps Pipeline

The repository enforces a pure GitOps model where all infrastructure changes are validated in Pull Requests before applying to production upon merging into `main`.

### 3.1 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── iam.tf
│   ├── secret_manager.tf
│   └── scripts/
│       └── startup.sh
└── README.md
```

### 3.2 Keyless GitHub Actions Authentication (Workload Identity Federation)

Instead of exporting long-lived GCP service account JSON keys to GitHub Secrets, the pipeline uses Workload Identity Federation. GitHub Actions exchanges an OpenID Connect (OIDC) token for short-lived GCP credentials.

```yaml
name: Terraform Apply
on:
  push:
    branches:
      - main
    paths:
      - 'terraform/**'
jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Authenticate to GCP via Workload Identity Federation
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
          service_account: 'terraform-deployer@PROJECT_ID.iam.gserviceaccount.com'
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: '1.8.0'
      - name: Terraform Init
        working-directory: ./terraform
        run: terraform init
      - name: Terraform Apply
        working-directory: ./terraform
        run: terraform apply -auto-approve
```

---

## 4. Infrastructure Specification (Terraform)

The core Terraform code provisions a decoupled architecture where the VM is ephemeral, but the agent's SQLite state, workspace data, and secret linkages persist independently.

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "YOUR_GCS_TERRAFORM_STATE_BUCKET"
    prefix = "nanoclaw/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Dedicated Least-Privilege VM Service Account
resource "google_service_account" "agent_sa" {
  account_id   = "nanoclaw-agent-runtime-sa"
  display_name = "NanoClaw Runtime Agent Service Account"
}

# Secret Manager Access for Gemini & Channel Tokens
resource "google_secret_manager_secret_iam_member" "gemini_api_key_accessor" {
  secret_id = "gemini-api-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "bot_token_accessor" {
  secret_id = "telegram-bot-token"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_sa.email}"
}

# Persistent Data Disk
resource "google_compute_disk" "agent_data" {
  name = "nanoclaw-data-disk"
  type = "pd-standard"
  size = 20
  zone = var.zone
  lifecycle {
    prevent_destroy = true
  }
}

# Compute Engine Instance
resource "google_compute_instance" "nanoclaw_vm" {
  name         = "nanoclaw-gemini-agent"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  attached_disk {
    source      = google_compute_disk.agent_data.id
    device_name = "agent-data"
    mode        = "READ_WRITE"
  }

  network_interface {
    network = "default"
    access_config {} # Outbound public IP for API endpoints & bot polling
  }

  service_account {
    email  = google_service_account.agent_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  tags = ["nanoclaw-agent"]
}
```

---

## 5. Host Provisioning & Startup Script (`startup.sh`)

The startup script automatically mounts persistent storage, installs the Docker engine and Node runtime, retrieves secrets via the `gcloud` CLI using instance IAM credentials, and registers a self-healing systemd daemon:

```bash
#!/bin/bash
set -euo pipefail

# 1. Mount Persistent Storage
DISK_DEV="/dev/disk/by-id/google-agent-data"
MOUNT_DIR="/opt/nanoclaw/data"

mkdir -p "$MOUNT_DIR"
if ! blkid "$DISK_DEV"; then
  mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0 "$DISK_DEV"
fi
mount -o discard,defaults "$DISK_DEV" "$MOUNT_DIR"
grep -q "$MOUNT_DIR" /etc/fstab || echo "$DISK_DEV $MOUNT_DIR ext4 discard,defaults,nofail 0 2" >> /etc/fstab

# 2. Install Runtime Dependencies
apt-get update
apt-get install -y docker.io git curl ca-certificates jq
systemctl enable --now docker
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g pnpm

# 3. Pull Secrets Securely from Secret Manager
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
GEMINI_KEY=$(gcloud secrets versions access latest --secret="gemini-api-key" --project="$PROJECT_ID")
BOT_TOKEN=$(gcloud secrets versions access latest --secret="telegram-bot-token" --project="$PROJECT_ID")

# 4. Clone or Update Agent Codebase
mkdir -p /opt/nanoclaw/app
if [ ! -d "/opt/nanoclaw/app/.git" ]; then
  git clone https://github.com/Rlin1027/NanoGemClaw.git /opt/nanoclaw/app
fi
cd /opt/nanoclaw/app
pnpm install

cat <<EOF > /opt/nanoclaw/app/.env
GEMINI_API_KEY=${GEMINI_KEY}
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
DATA_DIR=/opt/nanoclaw/data
NODE_ENV=production
EOF
chmod 600 /opt/nanoclaw/app/.env

# 5. Configure & Start Systemd Daemon
cat <<EOF > /etc/systemd/system/nanoclaw.service
[Unit]
Description=NanoClaw Gemini Agent Daemon
After=network.target docker.service

[Service]
Type=simple
WorkingDirectory=/opt/nanoclaw/app
ExecStart=/usr/bin/pnpm start
Restart=always
RestartSec=10
EnvironmentFile=/opt/nanoclaw/app/.env

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now nanoclaw.service
```

---

## 6. Security, Isolation & Operational Controls

- **Secret Isolation:** No API keys are stored in Git repositories, GitHub Action secrets, or Terraform state files. Secrets are provisioned in GCP Secret Manager and dynamically read at host boot.
- **Least Privilege IAM:** The runtime service account possesses read-only access strictly restricted to required Secret Manager versions and logging channels.
- **Container Sandbox:** NanoClaw executes user tools and bash actions inside lightweight, ephemeral Docker containers spawned per session rather than directly on the VM host.
- **Data Backup Policy:** A GCP Resource Policy attaches automated daily snapshots to `nanoclaw-data-disk` with a 14-day retention window to protect SQLite queues and agent memories.

---

## 7. Estimated Monthly Cost Breakdown

| Resource | Configuration | Estimated Monthly Cost |
| :--- | :--- | :--- |
| **Compute Engine VM** | `e2-small` (2 vCPU, 2GB RAM) - 24/7 uptime | ~$14.00 |
| **Boot Disk + Data Disk** | 40GB total Standard Persistent Disk | ~$1.60 |
| **Secret Manager & Network Egress** | Standard API calls + Outbound messaging traffic | < $0.50 |
| **Total Estimated Infrastructure Cost** | | **~$16.00 / month** |
