# Core Terraform Configuration for NanoGemClaw Infrastructure
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "nanogemclaw-tf-90326-nanoclaw-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Compute Resource Policy for Automated Daily Disk Snapshots
resource "google_compute_resource_policy" "nanoclaw_snapshot_policy" {
  name   = "nanoclaw-snapshot-policy"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 14
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      labels = {
        environment = "production"
        managed_by  = "terraform"
      }
    }
  }
}

# Persistent Data Disk for NanoGemClaw Agent State
resource "google_compute_disk" "agent_data" {
  name = "nanoclaw-data-disk"
  type = "pd-standard"
  zone = var.zone
  size = var.persistent_disk_size_gb

  lifecycle {
    prevent_destroy = true
  }
}

# Attach Snapshot Resource Policy to Persistent Disk
resource "google_compute_disk_resource_policy_attachment" "nanoclaw_snapshot_attachment" {
  name = google_compute_resource_policy.nanoclaw_snapshot_policy.name
  disk = google_compute_disk.agent_data.name
  zone = var.zone
}




# Compute Engine VM Host for NanoGemClaw Agent
resource "google_compute_instance" "nanoclaw_vm" {
  name         = "nanoclaw-gemini-agent"
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  attached_disk {
    source      = google_compute_disk.agent_data.id
    device_name = "agent-data"
    mode        = "READ_WRITE"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = google_service_account.agent_runtime_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = templatefile("${path.module}/../scripts/startup.sh", {
      container_image      = var.container_image
      persistent_disk_name = "agent-data"
      allowed_user_ids     = var.allowed_user_ids
    })
  }

  depends_on = [
    google_service_account.agent_runtime_sa,
    google_compute_disk.agent_data
  ]
}
