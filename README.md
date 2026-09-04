# NanoGemClawTF 🐾🤖

> **Declarative GitOps & Terraform Infrastructure for Hosting NanoGemClaw (Gemini Personal Agent) on GCP**

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D%201.5.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/GCP-Compute%20Engine%20%2B%20Gemini-4285F4?logo=google-cloud)](https://cloud.google.com/)
[![Guardian](https://img.shields.io/badge/CI%2FCD-abcxyz%2Fguardian-0F9D58?logo=github-actions)](https://github.com/abcxyz/guardian)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

**NanoGemClawTF** is an open-source, 100% forkable Infrastructure-as-Code (IaC) repository that provisions a secure, low-overhead hosting environment for **NanoGemClaw**—an autonomous personal agent harness powered by Google Gemini—on Google Cloud Platform (GCP).

---

## ✨ Key Product Features

- 🔒 **Zero-Trust & Keyless Authentication**: Keyless CI/CD authentication via GCP Workload Identity Federation (WIF) and GitHub Actions. No long-lived service account JSON keys.
- 🛡️ **Guardian-Driven GitOps**: Automated `terraform plan` reviews, policy enforcement, and `apply` workflows using [`abcxyz/guardian`](https://github.com/abcxyz/guardian).
- 💾 **Decoupled Ephemeral Compute**: VM host (`e2-small`) is disposable; SQLite state and agent memories persist on an attached 20GB GCP Persistent Disk mounted at `/opt/nanoclaw/data` via systemd mount units.
- 🐳 **Containerized Runtime & Scheduled Sync**: Pre-built immutable container image compiled daily to GHCR from `https://github.com/Rlin1027/NanoGemClaw` for instant, fast host boots without OOM crashes.
- 🔐 **Secret Isolation**: Gemini API keys and Telegram/Discord/Slack bot tokens are declaratively provisioned in GCP Secret Manager via Terraform and retrieved securely at boot.
- 🚫 **User Access Control**: Built-in user allowlist (`ALLOWED_USER_IDS`) prevents unauthorized access and protects your Gemini token budget.
- 🌐 **100% Publicly Reusable**: Zero hardcoded Project IDs or private details. Fully parameterized via GitHub Actions repository variables and secrets.

---

## 🏛️ System Architecture

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          GitHub Repository                             │
│       (Actions + GHCR Container Build + abcxyz/guardian)               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Workload Identity Federation (WIF)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        Google Cloud Platform                           │
│                                                                        │
│  ┌─────────────────────────┐         ┌──────────────────────────────┐  │
│  │   GCP Secret Manager    │         │     Compute Engine Instance  │  │
│  │ (Gemini Key, Bot Tokens)│         │         (e2-small)           │  │
│  └────────────┬────────────┘         │                              │  │
│               │ Dynamic fetch        │  ┌────────────────────────┐  │  │
│               └─────────────────────►│  │ Docker Container Daemon│  │  │
│                                      │  └───────────┬────────────┘  │  │
│                                      │              │ Container     │  │
│  ┌─────────────────────────┐         │              ▼ Sandbox       │  │
│  │  GCP Persistent Disk    │◄────────┤  ┌────────────────────────┐  │  │
│  │ (SQLite & Memory State) │ Mount   │  │ Ephemeral Tool Runner  │  │  │
│  └─────────────────────────┘         │  └────────────────────────┘  │  │
│                                      └──────────────┬───────────────┘  │
└─────────────────────────────────────────────────────┼──────────────────┘
                                                      │ Messaging Gateway
                                                      ▼ (Telegram/Discord/Slack)
                                                 ┌───────────┐
                                                 │   User    │
                                                 └───────────┘
```

---

## 🚀 Quickstart & Setup Guide

Want to deploy your own Gemini agent in under 10 minutes? Check out our dedicated **[Quickstart Guide](docs/quickstart.md)**.

### Required GitHub Variables & Secrets

Configure the following in your repository under **Settings → Secrets and variables → Actions**:

#### Variables (`vars`)
| Variable Name | Description | Example |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `my-gemini-agent-prod` |
| `GCP_REGION` | GCP Compute Region | `us-central1` |
| `GCP_ZONE` | GCP Compute Zone | `us-central1-a` |
| `GCP_TF_STATE_BUCKET` | GCP Storage Bucket for Terraform state | `my-gemini-agent-prod-nanoclaw-tfstate` |
| `GCP_WIF_PROVIDER` | Workload Identity Provider resource string | `projects/1234/locations/global/workloadIdentityPools/...` |
| `GCP_SERVICE_ACCOUNT` | Terraform deployer service account email | `terraform-deployer@my-proj.iam.gserviceaccount.com` |
| `ALLOWED_USER_IDS` | Comma-separated allowed messaging user IDs | `123456789` |

#### Secrets (`secrets`)
| Secret Name | Description |
| :--- | :--- |
| `GEMINI_API_KEY` | Google Gemini API Key |
| `TELEGRAM_BOT_TOKEN` | Bot Token from Telegram `@BotFather` (or Slack/Discord token) |

---

## 📚 Documentation

- 📖 **[Deployment Quickstart](docs/quickstart.md)** — Step-by-step setup guide for GCP, GitHub Actions, and initial deployment.
- 📐 **[Architecture Design Doc](docs/Overview.md)** — Detailed specification of GCP infrastructure, security boundaries, container runtimes, and systemd mount units.
- 📜 **[Project Constitution](.specify/memory/constitution.md)** — Governance rules, security principles, and non-negotiables.

---

## 📄 License

Distributed under the Apache 2.0 License. See [`LICENSE`](LICENSE) for more details.
