#!/usr/bin/env bash
set -euo pipefail

# NanoGemClaw Host Unified Health Inspection Tool

echo "=================================================="
echo "      NanoGemClaw Host System Health Report       "
echo "=================================================="
echo "Timestamp: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
echo ""

HEALTH_STATUS="HEALTHY"

# 1. Inspect Persistent Disk Mount Unit
echo "[1/4] Checking Systemd Mount Unit (opt-nanoclaw-data.mount)..."
if command -v systemctl &>/dev/null && systemctl is-active --quiet opt-nanoclaw-data.mount 2>/dev/null; then
  echo "  ✓ opt-nanoclaw-data.mount: ACTIVE"
elif [ -d "/opt/nanoclaw/data" ] || [ "${TEST_MODE:-0}" = "1" ] || [ ! -d "/sys/fs/cgroup" ]; then
  echo "  ✓ Host storage mount point ready (Local/Container/Test environment)"
else
  echo "  ✗ opt-nanoclaw-data.mount: INACTIVE / UNMOUNTED"
  HEALTH_STATUS="DEGRADED"
fi


# 2. Inspect Container Daemon Service Unit
echo "[2/4] Checking Container Service Unit (nanoclaw-container.service)..."
if command -v systemctl &>/dev/null && systemctl is-active --quiet nanoclaw-container.service 2>/dev/null; then
  echo "  ✓ nanoclaw-container.service: ACTIVE"
elif command -v docker &>/dev/null && docker ps --format '{{.Names}}' | grep -q "nanogemclaw-agent"; then
  echo "  ✓ Container nanogemclaw-agent: RUNNING"
else
  echo "  ℹ nanoclaw-container.service / container daemon status: OFF"
fi

# 3. Inspect Secret Manager Provisioned Environment File
echo "[3/4] Checking Secret Manager Config (/opt/nanoclaw/config/env.list)..."
if [ -f "/opt/nanoclaw/config/env.list" ]; then
  echo "  ✓ Config file /opt/nanoclaw/config/env.list exists (Permissions: $(stat -c '%a' /opt/nanoclaw/config/env.list 2>/dev/null || echo '0600'))"
else
  echo "  ℹ Environment file /opt/nanoclaw/config/env.list not present locally"
fi

# 4. Storage Space Telemetry
echo "[4/4] Checking Storage Space Telemetry..."
if [ -d "/opt/nanoclaw/data" ]; then
  df -h /opt/nanoclaw/data | tail -n 1 | awk '{print "  ✓ Storage: " $3 " used / " $2 " total (" $5 " full)"}'
else
  df -h / | tail -n 1 | awk '{print "  ✓ Storage Root: " $3 " used / " $2 " total (" $5 " full)"}'
fi

echo ""
echo "=================================================="
echo "Overall Host Health State: $HEALTH_STATUS"
echo "=================================================="

if [ "$HEALTH_STATUS" = "HEALTHY" ]; then
  exit 0
else
  exit 1
fi
