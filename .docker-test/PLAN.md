# GitHub Workflow Plan: Auto-Build & Push pi-agent to GHCR

## Overview

Create a GitHub Actions workflow that runs daily, checks for new versions of `@mariozechner/pi-coding-agent` on npm, and automatically builds + pushes the container image to GitHub Container Registry (ghcr.io).

---

## 1. GitHub Actions Workflow

### File: `.github/workflows/build.yml`

```yaml
name: Build and Push pi-agent

on:
  schedule:
    # Run daily at 06:00 UTC
    - cron: '0 6 * * *'
  workflow_dispatch: # Allow manual triggers
  push:
    branches: [main]
    paths:
      - 'Dockerfile'
      - '.github/workflows/build.yml'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  check-and-build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Get latest pi-agent version from npm
        id: npm-version
        run: |
          LATEST=$(npm view @mariozechner/pi-coding-agent version)
          echo "version=$LATEST" >> $GITHUB_OUTPUT
          echo "Latest version: $LATEST"

      - name: Check if image exists for this version
        id: check-image
        continue-on-error: true
        run: |
          docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.npm-version.outputs.version }} || echo "Image not found"

      - name: Set up Docker Buildx
        if: steps.check-image.outcome == 'failure'
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        if: steps.check-image.outcome == 'failure'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        if: steps.check-image.outcome == 'failure'
        uses: docker/build-push-action@v5
        with:
          context: .
          build-args: |
            PI_VERSION=${{ steps.npm-version.outputs.version }}
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.npm-version.outputs.version }}
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Summary
        run: |
          if [ "${{ steps.check-image.outcome }}" == "failure" ]; then
            echo "✅ New version ${{ steps.npm-version.outputs.version }} built and pushed!"
          else
            echo "⏭️ Version ${{ steps.npm-version.outputs.version }} already exists. Skipping build."
          fi
```

### Workflow Behavior

| Trigger | Action |
|---------|--------|
| Daily schedule (6 AM UTC) | Check npm for latest version, build if not in ghcr |
| Manual dispatch | Same as above |
| Push to main (Dockerfile/workflow changed) | Force rebuild |

---

## 2. Repository Adaptations

### Update `README.md`

Replace the local build instructions with ghcr.io instructions:

```markdown
# pi-agent container

Run the pi coding agent in a container.

## Usage

```bash
# Pull the image
podman pull ghcr.io/<OWNER>/pi-agent:latest

# Alias
alias pi='podman run --rm -it \
  --user $(id -u):$(id -g) \
  -v "$HOME/.pi:/home/node/.pi" \
  -v "$HOME/.agents:/home/node/.agents" \
  -v "$(pwd):/workspace" \
  -w /workspace \
  ghcr.io/<OWNER>/pi-agent'
```

## Versions

Images are tagged with:
- `latest` - most recent build
- `0.61.1` - specific version (matches npm package version)

The image is automatically built daily when new versions are published to npm.
```

### Add `.dockerignore`

```
.git
.github
*.md
PLAN.md
```

---

## 3. Version Tracking (Optional Enhancement)

For more robust version tracking, consider adding a `VERSION` file that stores the last built version. The workflow would:
1. Read `VERSION` file
2. Query npm for latest
3. If different, build and update `VERSION` file (commit back to repo)

### Alternative: Use Git Tags

Instead of a VERSION file, use git tags:
- Tag each build as `v<version>` (e.g., `v0.61.1`)
- Check if tag exists before building
- Create tag after successful push

---

## 4. Implementation Steps

1. [ ] Create `.github/workflows/` directory
2. [ ] Add `build.yml` workflow file
3. [ ] Update `README.md` with ghcr.io instructions
4. [ ] Create `.dockerignore` file
5. [ ] Enable GitHub Packages for the repository
6. [ ] Test with manual workflow dispatch
7. [ ] Verify image appears in ghcr.io

---

## 5. GitHub Settings Required

- **Packages**: Must be enabled for the repository
- **Permissions**: `GITHUB_TOKEN` needs `packages: write` permission (default for workflows in public repos)
- For private repos, may need to adjust Actions permissions in Settings > Actions > General

---

## 6. Future Enhancements

- [ ] Multi-arch builds (amd64, arm64)
- [ ] Vulnerability scanning with `trivy`
- [ ] Slack/Discord notification on new builds
- [ ] Automated testing before push
- [ ] Scheduled cleanup of old image versions