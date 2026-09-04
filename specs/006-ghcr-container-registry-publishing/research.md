# Research & Technology Selection: GHCR Package Publishing & Multi-Tagging Strategy

## 1. Registry & Authentication
- **Registry Endpoint**: GitHub Container Registry (`ghcr.io`).
- **Image Name**: `ghcr.io/${{ github.repository_owner }}/nanogemclaw`.
- **Authentication**: `docker/login-action@v3` using `registry: ghcr.io`, `username: ${{ github.actor }}`, `password: ${{ secrets.GITHUB_TOKEN }}`.
- **Workflow Permissions**: `permissions: contents: read`, `packages: write`.

## 2. Docker Metadata & Tagging Strategy
- **Action**: `docker/metadata-action@v5`.
- **Tags Configuration**:
  - `type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' || github.event_name == 'workflow_dispatch' || github.event_name == 'schedule' }}`
  - `type=sha,prefix=sha-,format=short`
  - `type=schedule,pattern={{date 'YYYYMMDD'}}`
  - `type=raw,value={{date 'YYYYMMDD'}}`
- **Flavor**: `lower=true` (converts repository owner to lowercase for Docker URI compliance).

## 3. Provenance & Annotations
- **OIDC Annotations**: Enabled automatically by `docker/metadata-action` and `docker/build-push-action@v5`.
- **Buildx Integration**: `docker/build-push-action@v5` with `push: ${{ github.event_name != 'pull_request' || github.event_name == 'workflow_dispatch' }}` (or push on pull_request testing/build).

## 4. Verification & Testing Strategy
- Local validation via syntax check and workflow inspection.
- PR CI run to verify build and metadata extraction steps.
