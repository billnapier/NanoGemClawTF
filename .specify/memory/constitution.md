<!--
SYNC IMPACT REPORT
- Version change: 1.1.0 → 1.2.0
- Ratification Date: 2026-09-04
- Last Amended Date: 2026-09-04
- Modified Principles:
  - Added Principle 3: Public Reusability, Forkability & Zero Private Leakage (mandating 100% parameterization via GitHub Actions variables/secrets with zero hardcoded private values).
  - Renumbered subsequent principles (Decoupled State → Principle 4, Least Privilege → Principle 5, Predictable Cost → Principle 6).
- Added/Updated Sections: Tech Stack & Architecture Constraints updated with strict parameterization rules.
- Templates Status:
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: None
-->

# NanoGemClawTF Project Constitution

**Version:** 1.2.0  
**Ratification Date:** 2026-09-04  
**Last Amended Date:** 2026-09-04  

---

## 1. Project Vision & Scope

**NanoGemClawTF** defines and maintains the declarative Infrastructure-as-Code (IaC) and automated GitOps deployment pipeline for hosting **NanoGemClaw** (an autonomous personal agent harness using Google Gemini for multimodal reasoning) on Google Cloud Platform (GCP).

The scope encompasses:
- Decoupled, cost-efficient GCP infrastructure provisioned exclusively via Terraform.
- Automated GitOps CI/CD pipelines managed by **abcxyz/guardian** via GitHub Actions with GCP Workload Identity Federation (WIF).
- 100% forkable, parameter-driven design with strict zero-leakage protection for public repository safety.
- Secure runtime host configuration, persistent disk isolation, and secret management.
- Ephemeral container sandboxing for personal agent tool execution.

---

## 2. Core Non-Negotiable Principles

### Principle 1: Declarative IaC & Guardian-Driven GitOps Deployment
- **Rule:** ALL GCP infrastructure resources (Compute Engine, Persistent Disks, IAM roles, Secret Manager secrets) MUST be declared in Terraform (`terraform/*.tf`) and executed through **abcxyz/guardian** (http://github.com/abcxyz/guardian) via automated GitHub Actions pipelines upon pull requests and merges to `main`. Direct manual resource creation or modification via the GCP Console or `gcloud` CLI is STRICTLY PROHIBITED in production environments.
- **Rationale:** Guarantees automated plan/apply execution, drift detection, policy enforcement, and complete auditability across all infrastructure state changes.

### Principle 2: Zero-Trust Security & Secret Isolation
- **Rule:** Long-lived GCP service account JSON key files or hardcoded credentials MUST NEVER be generated, committed to version control, or stored in GitHub Secrets. CI/CD pipelines MUST use GCP Workload Identity Federation (WIF) with OIDC tokens. Application secrets (Gemini API keys, bot tokens) MUST be stored in GCP Secret Manager and retrieved dynamically at runtime.
- **Rationale:** Eliminates credential leakage vectors and enforces short-lived, verifiable identity delegation between GitHub Actions and Google Cloud.

### Principle 3: Public Reusability, Forkability & Zero Private Leakage
- **Rule:** As a public repository, the codebase MUST NEVER contain private configuration details, hardcoded GCP Project IDs, account emails, internal domain names, state bucket names, or user-specific values. ALL site-specific or user-specific customizations MUST be parameterized via GitHub Actions repository variables (`vars.*`), secrets (`secrets.*`), or environment variables passed to Terraform at runtime. The infrastructure code MUST be 100% forkable and reusable out-of-the-box by any third party without needing code modifications.
- **Rationale:** Protects maintainers and contributors against accidental private data exposure while empowering the open-source community to deploy their own instances seamlessly.

### Principle 4: Decoupled State & Ephemeral Compute Runtime
- **Rule:** The Virtual Machine host (Compute Engine `e2-small`) MUST be treated as disposable and ephemeral. All agent state, SQLite databases, and persistent files MUST reside on an independent, attached GCP Persistent Disk (`pd-standard`) mounted at `/opt/nanoclaw/data` with snapshot policies enabled.
- **Rationale:** Ensures zero data loss during host restarts, VM migrations, or OS security updates, decoupling infrastructure lifecycle from agent memory retention.

### Principle 5: Least-Privilege IAM & Sandboxed Execution
- **Rule:** The Compute Engine runtime service account MUST be granted only minimum required IAM roles (e.g. `roles/secretmanager.secretAccessor`). Agent tool executions and arbitrary user commands MUST run inside isolated, ephemeral Docker containers spawned per session rather than directly on the VM host.
- **Rationale:** Protects the host system and GCP environment from untrusted tool outputs or potential container breakout risks.

### Principle 6: Predictable Cost & Minimal Operational Overhead
- **Rule:** Infrastructure choices MUST prioritize minimal idle resource consumption and predictable monthly budgets (~$16/month baseline). Automated lifecycle policies, resource rightsizing, and minimal background daemons MUST be enforced.
- **Rationale:** Keeps operating costs low and avoids resource creep while delivering high performance for personal agent automation.

---

## 3. Tech Stack & Architecture Constraints

- **IaC Engine:** Terraform `>= 1.5.0` with standard HashiCorp Google provider (`~> 5.0`).
- **IaC Automation & Governance:** **abcxyz/guardian** (`github.com/abcxyz/guardian`) for automated workflows, plan reviews, policy checks, and apply execution.
- **Parameterization:** All GCP Project IDs, region/zone settings, state bucket configurations, and IAM identifiers MUST be parameterized via Terraform variables (`variables.tf`) and injected via GitHub Actions repository variables (`vars.*`).
- **State Backend:** Configurable GCP Cloud Storage (GCS) backend initialized via backend configuration parameters (`-backend-config`).
- **Cloud Provider:** Google Cloud Platform (GCP), region/zone-configurable via Terraform variables.
- **Host OS:** Debian 12 (Compute Engine `e2-small` instance).
- **CI/CD:** GitHub Actions using `google-github-actions/auth@v2` with Workload Identity Federation + `abcxyz/guardian`.
- **Secrets Management:** GCP Secret Manager with dynamic runtime retrieval via `startup.sh`.
- **Runtime Dependencies:** Node.js 20.x, `pnpm`, Docker Engine, `systemd` daemon management.

---

## 4. Governance & Amendment Policy

1. **Amendment Procedure:** Any change to this Constitution requires a formal proposal via a GitHub Pull Request detailing the rationale and impact on existing infrastructure.
2. **Versioning Policy:**
   - **MAJOR (X.0.0):** Removal or fundamental redefinition of core non-negotiable principles or security architecture.
   - **MINOR (1.X.0):** Addition of new principles, tech stack expansions, or structural governance updates.
   - **PATCH (1.0.X):** Wording clarifications, typo fixes, or non-semantic refinements.
3. **Compliance Verification:** All pull requests and infrastructure specs MUST be validated against these 6 core principles prior to approval.
