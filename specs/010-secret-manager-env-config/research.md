# Research: Secret Manager Access on GCE

## Key Findings

1. **Metadata Project Lookup**: GCE instances resolve project ID via `curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id`.
2. **Gcloud CLI Access**: The GCE instance runtime service account has `roles/secretmanager.secretAccessor` (provisioned in Spec 002 `secret_manager.tf`), enabling `gcloud secrets versions access latest --secret=...` without static credentials.
