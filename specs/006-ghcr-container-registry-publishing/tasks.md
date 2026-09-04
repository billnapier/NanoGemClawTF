# Tasks: GHCR Package Publication & Multi-Tagging Strategy

- [x] **Phase 1: Planning & Design**
  - [x] Create research.md, data-model.md, plan.md, and quickstart.md for Spec 006

- [x] **Phase 2: Workflow Updates (`.github/workflows/build-container.yml`)**
  - [x] Task 2.1: Add `packages: write` permissions and `push: branches: [main]` trigger to workflow definition
  - [x] Task 2.2: Add `docker/login-action@v3` step for `ghcr.io` authentication using `GITHUB_TOKEN`
  - [x] Task 2.3: Add `docker/metadata-action@v5` step configured for multi-tagging (`latest`, commit SHA, date timestamp) with lowercase owner conversion
  - [x] Task 2.4: Update `docker/build-push-action@v5` step to push images to GHCR using extracted tags and labels

- [x] **Phase 3: Verification & Review**
  - [x] Task 3.1: Perform code review and YAML linting on modified workflow file
  - [x] Task 3.2: Verify workflow execution local compatibility and git status
