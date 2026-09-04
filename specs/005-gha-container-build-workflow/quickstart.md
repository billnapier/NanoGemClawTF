# Quickstart & Verification: GitHub Actions Container Build Pipeline

**Feature Branch**: `005-gha-container-build-workflow`  
**Date**: 2026-09-04  
**Spec**: [spec.md](./spec.md)

---

## Testing & Operational Verification Steps

### 1. Workflow Syntax Validation
Validate the GitHub Actions YAML file locally using `actionlint` or basic YAML verification:
```bash
python3 -c "yaml=__import__('yaml'); yaml.safe_load(open('.github/workflows/build-container.yml'))"
```

### 2. Triggering Manual Container Build
Trigger the container build workflow manually via GitHub CLI:
```bash
gh workflow run build-container.yml
```

### 3. Monitoring Execution
Watch the workflow execution progress:
```bash
gh run list --workflow=build-container.yml
gh run watch
```

### 4. PR Verification
Verify that any PR editing `.github/workflows/build-container.yml` automatically triggers the build validation job and passes status checks before merging.
