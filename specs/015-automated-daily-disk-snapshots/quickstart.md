# Quickstart - Automated Daily Disk Snapshots

## Verification Steps
1. Validate Terraform configuration:
   ```bash
   cd terraform && terraform init -backend=false && terraform validate
   ```
2. Run snapshot policy verification test:
   ```bash
   python3 -m unittest discover -s tests -p "test_snapshot*.py"
   ```
