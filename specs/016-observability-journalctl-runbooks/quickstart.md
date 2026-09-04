# Quickstart - Observability & Operational Runbooks

## Verification Steps
1. Run host health check script:
   ```bash
   ./scripts/health_check.sh
   ```
2. Verify journalctl log inspection commands:
   ```bash
   journalctl -u nanoclaw-container.service -n 50 --no-pager
   ```
3. Run observability unit test suite:
   ```bash
   python3 -m unittest discover -s tests -p "test_observability*.py"
   ```
