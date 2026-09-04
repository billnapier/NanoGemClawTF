#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# NanoGemClawTF Phase 1 Deployment Verification Script
# ==============================================================================
# Non-destructively audits provisioned Phase 1 GCP resources:
# - Compute Engine VM instance status (nanoclaw-gemini-agent)
# - Persistent Disk attachment (nanoclaw-data-disk)
# - Secret Manager secret versions (gemini-api-key, telegram-bot-token)
# - GCS Remote State object (default.tfstate)
# - Serial port startup logs
# ==============================================================================

if [ -z "${GCP_PROJECT_ID:-}" ]; then
  echo "Error: GCP_PROJECT_ID environment variable is required."
  echo "Usage: GCP_PROJECT_ID=\"your-project-id\" $0"
  exit 1
fi

ZONE="${GCP_ZONE:-us-central1-a}"
STATE_BUCKET="${GCP_TF_STATE_BUCKET:-${GCP_PROJECT_ID}-nanoclaw-tfstate}"
VM_NAME="nanoclaw-gemini-agent"
DISK_NAME="nanoclaw-data-disk"

echo "=== 🔍 Auditing Phase 1 GCP Infrastructure Deployment ==="
echo "Project ID  : ${GCP_PROJECT_ID}"
echo "Zone        : ${ZONE}"
echo "State Bucket: ${STATE_BUCKET}"
echo "=========================================================="

ERRORS=0

# 1. Audit Compute Engine VM Status
echo -n "--> Checking VM Instance status (${VM_NAME})... "
if VM_STATUS=$(gcloud compute instances describe "${VM_NAME}" --zone="${ZONE}" --project="${GCP_PROJECT_ID}" --format="value(status)" 2>/dev/null); then
  echo "✅ [${VM_STATUS}]"
else
  echo "❌ NOT FOUND or ACCESS DENIED"
  ERRORS=$((ERRORS + 1))
fi

# 2. Audit Persistent Disk Status
echo -n "--> Checking Persistent Disk status (${DISK_NAME})... "
if DISK_STATUS=$(gcloud compute disks describe "${DISK_NAME}" --zone="${ZONE}" --project="${GCP_PROJECT_ID}" --format="value(status)" 2>/dev/null); then
  echo "✅ [${DISK_STATUS}]"
else
  echo "❌ NOT FOUND or ACCESS DENIED"
  ERRORS=$((ERRORS + 1))
fi

# 3. Audit Secret Manager Secrets
echo -n "--> Checking Secret Manager: gemini-api-key... "
if gcloud secrets describe gemini-api-key --project="${GCP_PROJECT_ID}" &>/dev/null; then
  echo "✅ EXISTS"
else
  echo "❌ NOT FOUND"
  ERRORS=$((ERRORS + 1))
fi

echo -n "--> Checking Secret Manager: telegram-bot-token... "
if gcloud secrets describe telegram-bot-token --project="${GCP_PROJECT_ID}" &>/dev/null; then
  echo "✅ EXISTS"
else
  echo "❌ NOT FOUND"
  ERRORS=$((ERRORS + 1))
fi

# 4. Audit GCS Remote State Persistence
echo -n "--> Checking GCS Remote State (gs://${STATE_BUCKET}/default.tfstate)... "
if gcloud storage ls "gs://${STATE_BUCKET}/default.tfstate" --project="${GCP_PROJECT_ID}" &>/dev/null; then
  echo "✅ PRESENT"
else
  echo "⚠️ STATE FILE NOT FOUND (Initial apply pending)"
fi

# 5. Serial Port Startup Audit (If VM is RUNNING)
if [ "${VM_STATUS:-}" = "RUNNING" ]; then
  echo "--> Auditing VM serial port startup output..."
  if gcloud compute instances get-serial-port-output "${VM_NAME}" --zone="${ZONE}" --project="${GCP_PROJECT_ID}" 2>/dev/null | grep -i "startup.sh" | tail -n 5; then
    echo "✅ Serial port log entries captured."
  else
    echo "ℹ️ Serial port logs initializing..."
  fi
fi

echo ""
echo "=========================================================="
if [ ${ERRORS} -eq 0 ]; then
  echo "🎉 Phase 1 Infrastructure Verification PASSED!"
  exit 0
else
  echo "❌ Phase 1 Infrastructure Verification Found ${ERRORS} Issue(s)."
  exit 1
fi
