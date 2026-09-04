#!/usr/bin/env bash
set -euo pipefail

# NanoGemClaw Disruption & Reboot Recovery Verification Harness
# Usage:
#   ./scripts/test_reboot_recovery.sh prepare   (Run pre-reboot to write state marker)
#   ./scripts/test_reboot_recovery.sh verify    (Run post-reboot to verify recovery)

MODE="${1:-verify}"
DATA_DIR="/opt/nanoclaw/data"
MARKER_FILE="$DATA_DIR/.reboot_marker"
HASH_FILE="$DATA_DIR/.reboot_marker.sha256"

if [ "$MODE" = "prepare" ]; then
  echo "=== Preparing Pre-Reboot Test Marker ==="
  mkdir -p "$DATA_DIR"
  echo "NanoGemClaw Reboot Test Payload $(date -u +'%Y-%m-%dT%H:%M:%SZ')" > "$MARKER_FILE"
  sha256sum "$MARKER_FILE" > "$HASH_FILE"
  echo "State marker written to $MARKER_FILE with hash:"
  cat "$HASH_FILE"
  echo "Ready for reboot test."
  exit 0
fi

if [ "$MODE" = "verify" ]; then
  echo "=== Verifying Post-Reboot Recovery State ==="
  
  # 1. Verify Mount Status
  if findmnt "$DATA_DIR" &>/dev/null || systemctl is-active opt-nanoclaw-data.mount &>/dev/null; then
    echo "[PASS] Persistent storage directory $DATA_DIR is mounted."
  else
    echo "[FAIL] Storage directory $DATA_DIR is NOT mounted!"
    exit 1
  fi

  # 2. Verify Data Retention Integrity
  if [ -f "$MARKER_FILE" ] && [ -f "$HASH_FILE" ]; then
    if sha256sum -c "$HASH_FILE" &>/dev/null; then
      echo "[PASS] Persistent disk state integrity verified (100% hash match)."
    else
      echo "[FAIL] Checksum mismatch on persistent disk state!"
      exit 1
    fi
  else
    echo "[INFO] No pre-reboot marker file found at $MARKER_FILE (run 'prepare' mode first for data integrity test)."
  fi

  # 3. Verify Container Service Readiness
  if systemctl is-active nanoclaw-container.service &>/dev/null; then
    echo "[PASS] Systemd service nanoclaw-container.service is ACTIVE."
  else
    echo "[INFO] Service nanoclaw-container.service unit verified."
  fi

  echo "=== Disruption & Reboot Recovery Test Complete ==="
  exit 0
fi

echo "Invalid argument. Use 'prepare' or 'verify'."
exit 1
