# Tasks: Compute Engine Provisioning & Startup Harness

- [x] Task 1: Add `allowed_user_ids` variable definition to `terraform/variables.tf`
- [x] Task 2: Update `google_compute_instance.nanoclaw_vm` in `terraform/main.tf` to set `device_name = "agent-data"` and pass `allowed_user_ids` to startup script template
- [x] Task 3: Update `scripts/startup.sh` template header parameters to support `allowed_user_ids`
- [x] Task 4: Run `terraform validate` to verify HCL correctness
