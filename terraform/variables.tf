variable "project_id" {
  description = "The GCP Project ID where resources will be provisioned."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for compute resources."
  type        = string
  default     = "us-central1-a"
}

variable "github_repo" {
  description = "The target GitHub repository in org/repo format (e.g. billnapier/NanoGemClawTF)."
  type        = string
  default     = "billnapier/NanoGemClawTF"
}

variable "state_bucket_name" {
  description = "The GCS storage bucket name for Terraform remote state."
  type        = string
  default     = ""
}
