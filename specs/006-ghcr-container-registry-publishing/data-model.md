# Data Model: GHCR Container Registry Package & Workflow Entities

## Entities

### GHCR Package Entity
- **Registry**: `ghcr.io`
- **Namespace**: Lowercase GitHub Owner (`${{ github.repository_owner }}`)
- **Package Name**: `nanogemclaw`
- **Full Image URI Format**: `ghcr.io/<owner>/nanogemclaw:<tag>`

### Image Tags Scheme
1. `latest`: Pointer to the most recent successful build on `main` branch or scheduled release.
2. `sha-<commit_sha>`: Immutable reference to specific git commit (e.g., `sha-a1b2c3d`).
3. `YYYYMMDD`: Date-based build timestamp tag (e.g., `20260904`).

### Workflow Security & IAM Model
- **Token**: Standard GitHub Actions `GITHUB_TOKEN`.
- **Permissions**:
  - `contents: read`
  - `packages: write`
- **Scope**: Tied strictly to the repository container registry scope.
