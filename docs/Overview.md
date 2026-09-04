# Design Doc: GitOps & Terraform Infrastructure for NanoClaw with Gemini on GCP

**Status:** Approved  
**Author:** Engineering  
**Last Updated:** September 2026  

---

## 1. Executive Summary & Objective

This design document establishes the infrastructure, security model, and automated GitOps deployment pipeline for hosting a low-overhead, autonomous personal agent harness based on the **NanoClaw** (or **NanoGemClaw**) architecture on Google Cloud Platform (GCP). The system utilizes **Google Gemini** for multimodal reasoning and function calling, while enforcing declarative Infrastructure-as-Code (IaC) via **Terraform** and continuous delivery via **GitHub Actions** and **`abcxyz/guardian`**.

The primary goal is to minimize idle daemon overhead, token consumption, and operational friction compared to heavy agent frameworks while providing state retention, sandboxed tool execution, strict user access control, and secure, keyless automation from GitHub.

For a step-by-step setup guide for forking and deploying, see the **[Deployment Quickstart](quickstart.md)**.

---

## 2. Architectural Overview

The system architecture separates declarative infrastructure orchestration, CI/CD automation, VM runtime hosting, and agent execution layers:

| Layer | Component | Description & Role |
| :--- | :--- | :--- |
| **GitOps / CI/CD** | GitHub Actions + `abcxyz/guardian` + WIF | Executes automated `terraform plan` reviews, policy enforcement, and `apply` workflows using keyless GCP Workload Identity Federation. |
| **Container Registry** | GitHub Container Registry (GHCR) | Holds pre-built immutable Docker container images compiled daily via GHA workflow from `https://github.com/Rlin1027/NanoGemClaw`. |
| **Infrastructure** | Google Compute Engine (GCE) | Lightweight `e2-small` Debian 12 virtual machine hosting Docker container runtime and systemd mounts. |
| **State Storage** | GCP Persistent Disk (Zonal) | Separate 20GB Persistent Disk mounted to `/opt/nanoclaw/data` via systemd mount unit (`opt-nanoclaw-data.mount`) retaining SQLite databases and file memory across VM recreations. |
| **Secrets Layer** | GCP Secret Manager | Stores Gemini API keys and messaging gateway tokens (Telegram, Discord, Slack) declaratively provisioned via Terraform without committing secrets. |
| **Agent Harness** | NanoGemClaw Container Daemon | Ephemeral Docker container running Node.js host daemon that coordinates message channels, enforces `ALLOWED_USER_IDS` access control, and dispatches tool execution. |
| **Model Inference** | Google Gemini API | Powers reasoning, context processing, fast-path routing, and structured function calling. |

---

## 3. Repository Layout & GitOps Pipeline

The repository enforces a pure GitOps model where all infrastructure changes are validated in Pull Requests before applying to production upon merging into `main`.

### 3.1 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── build-container.yml   # Scheduled daily cron & manual workflow to build GHCR image
│       ├── terraform-plan.yml    # Managed via abcxyz/guardian
│       └── terraform-apply.yml   # Managed via abcxyz/guardian
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── iam.tf
│   ├── secret_manager.tf
│   └── scripts/
│       └── startup.sh
├── docs/
│   ├── Overview.md               # This design document
│   └── quickstart.md             # Step-by-step setup guide
└── README.md
```

### 3.2 Keyless GitHub Actions Authentication (Workload Identity Federation)

Instead of exporting long-lived GCP service account JSON keys to GitHub Secrets, the pipeline uses Workload Identity Federation. GitHub Actions exchanges an OpenID Connect (OIDC) token for short-lived GCP credentials. Dynamic backend state parameters are passed directly via `GCP_TF_STATE_BUCKET`.

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
          workload_identity_provider: ${{ vars.GCP_WIF_PROVIDER }}
          service_account: ${{ vars.GCP_SERVICE_ACCOUNT }}
      - name: Setup Guardian & Terraform
        uses: abcxyz/guardian/actions/setup@v1
        with:
          terraform_version: '1.8.0'
      - name: Guardian Terraform Init & Apply
        run: |
          guardian entrypoints apply \
            -backend-config="bucket=${{ vars.GCP_TF_STATE_BUCKET }}"
        env:
          TF_VAR_project_id: ${{ vars.GCP_PROJECT_ID }}
          TF_VAR_region: ${{ vars.GCP_REGION }}
          TF_VAR_zone: ${{ vars.GCP_ZONE }}
          TF_VAR_allowed_user_ids: ${{ vars.ALLOWED_USER_IDS }}
          TF_VAR_gemini_api_key: ${{ secrets.GEMINI_API_KEY }}
          TF_VAR_telegram_bot_token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
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
    # Backend configuration passed dynamically at init via -backend-config
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

# Secret Manager Containers & Secret Versions
resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "gemini-api-key"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "gemini_api_key_version" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = var.gemini_api_key
}

resource "google_secret_manager_secret" "telegram_bot_token" {
  secret_id = "telegram-bot-token"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "telegram_bot_token_version" {
  secret      = google_secret_manager_secret.telegram_bot_token.id
  secret_data = var.telegram_bot_token
}

# Secret Manager IAM Accessor Bindings
resource "google_secret_manager_secret_iam_member" "gemini_api_key_accessor" {
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "bot_token_accessor" {
  secret_id = google_secret_manager_secret.telegram_bot_token.secret_id
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

  metadata_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    allowed_user_ids = var.allowed_user_ids,
    container_image  = var.container_image
  })

  tags = ["nanoclaw-agent"]
}
```

---

## 5. Host Provisioning & Systemd Mount Configuration (`startup.sh`)

The startup script formats persistent storage if necessary, provisions a native systemd mount unit (`opt-nanoclaw-data.mount`), retrieves runtime secrets from GCP Secret Manager, and configures a systemd service (`nanoclaw-container.service`) bound by `Requires=opt-nanoclaw-data.mount` to prevent root disk data overlay:

```bash
#!/bin/bash
set -euo pipefail

# 1. Block Device & Persistent Storage Setup
DISK_DEV="/dev/disk/by-id/google-agent-data"
MOUNT_DIR="/opt/nanoclaw/data"

mkdir -p "$MOUNT_DIR"
until [ -b "$DISK_DEV" ]; do
  echo "Waiting for $DISK_DEV block device to enumerate..."
  sleep 2
done

if ! blkid "$DISK_DEV"; then
  mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0 "$DISK_DEV"
fi

# 2. Systemd Mount Unit Registration
cat <<EOF > /etc/systemd/system/opt-nanoclaw-data.mount
[Unit]
Description=NanoClaw Agent Persistent Data Mount
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target

[Mount]
What=$DISK_DEV
Where=$MOUNT_DIR
Type=ext4
Options=discard,defaults,nofail

[Install]
WantedBy=local-fs.target
EOF

systemctl daemon-reload
systemctl enable --now opt-nanoclaw-data.mount

# 3. Install Docker Engine & Dependencies
apt-get update
apt-get install -y docker.io curl jq ca-certificates
systemctl enable --now docker

# 4. Fetch Secrets from GCP Secret Manager
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
GEMINI_KEY=$(gcloud secrets versions access latest --secret="gemini-api-key" --project="$PROJECT_ID")
BOT_TOKEN=$(gcloud secrets versions access latest --secret="telegram-bot-token" --project="$PROJECT_ID")

mkdir -p /opt/nanoclaw/config
cat <<EOF > /opt/nanoclaw/config/env.list
GEMINI_API_KEY=${GEMINI_KEY}
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
ALLOWED_USER_IDS=${allowed_user_ids}
DATA_DIR=/opt/nanoclaw/data
NODE_ENV=production
LOG_LEVEL=info
EOF
chmod 600 /opt/nanoclaw/config/env.list

# 5. Register Systemd Container Daemon with Storage Requirement
cat <<EOF > /etc/systemd/system/nanoclaw-container.service
[Unit]
Description=NanoGemClaw Containerized Agent Daemon
Requires=opt-nanoclaw-data.mount docker.service
After=opt-nanoclaw-data.mount docker.service

[Service]
Type=simple
ExecStartPre=/usr/bin/docker pull ${container_image}
ExecStart=/usr/bin/docker run --rm \
  --name nanogemclaw-agent \
  --env-file /opt/nanoclaw/config/env.list \
  -v /opt/nanoclaw/data:/opt/nanoclaw/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${container_image}
ExecStop=/usr/bin/docker stop nanogemclaw-agent
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now nanoclaw-container.service
```

---

## 6. Security, Isolation & Operational Controls

- **Declarative Secret Provisioning:** Secrets are defined via Terraform `secret_manager.tf` and stored in GCP Secret Manager, retrieved dynamically at boot by the VM service account.
- **Systemd Storage Isolation:** Systemd mount unit dependencies strictly prevent the container runtime from starting unless the persistent disk is mounted at `/opt/nanoclaw/data`.
- **Immutable Container Runtime:** Pre-built container images published to GHCR prevent host compilation failures and Out-Of-Memory errors on low-spec VMs.
- **User Access Control:** Incoming messages from users not listed in `ALLOWED_USER_IDS` are strictly ignored/rejected to protect Gemini API token quotas.
- **Data Backup Policy:** A GCP Resource Policy attaches automated daily snapshots to `nanoclaw-data-disk` with a 14-day retention window to protect SQLite queues and agent memories.

---

## 7. Estimated Monthly Cost Breakdown

| Resource | Configuration | Estimated Monthly Cost |
| :--- | :--- | :--- |
| **Compute Engine VM** | `e2-small` (2 vCPU, 2GB RAM) - 24/7 uptime | ~$14.00 |
| **Boot Disk + Data Disk** | 40GB total Standard Persistent Disk | ~$1.60 |
| **Secret Manager & Container Registry** | Standard API calls + GHCR image storage | < $0.50 |
| **Total Estimated Infrastructure Cost** | | **~$16.00 / month** |
