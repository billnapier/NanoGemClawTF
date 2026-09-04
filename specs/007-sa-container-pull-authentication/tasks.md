# Tasks: Compute Engine SA Container Pull & Image Verification

- [x] **Phase 1: Planning & Design**
  - [x] Create research.md, data-model.md, plan.md, and quickstart.md for Spec 007

- [x] **Phase 2: Terraform & Script Modifications**
  - [x] Task 2.1: Update `terraform/variables.tf` default `container_image` to `ghcr.io/billnapier/nanogemclaw:latest`
  - [x] Task 2.2: Verify `scripts/startup.sh` script pull handling for dynamic container image URI

- [x] **Phase 3: Validation & CI**
  - [x] Task 3.1: Execute `terraform validate` and `terraform fmt` check
  - [x] Task 3.2: Verify git status and update `.specify/STATUS.md`
