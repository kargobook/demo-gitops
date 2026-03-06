# CLAUDE.md — demo-gitops

Public companion GitOps repository for *Continuous Promotion with Kargo* (O'Reilly, 2026).
Canonical location: https://github.com/kargobook/demo-gitops

Readers fork this repo. Kargo pushes promotion commits to the fork to update image tags.

## Structure

```
base/                          # Kustomize base: Deployment + Service
envs/
  dev/kustomization.yaml       # Dev overlay  — namespace: demo-dev
  staging/kustomization.yaml   # Staging overlay — namespace: demo-staging
  prod/kustomization.yaml      # Prod overlay — namespace: demo-prod
setup/                         # One-time cluster resources (applied manually; not watched by Argo CD)
  00-namespaces.yaml
  01-argocd-apps.yaml          # Three Argo CD Applications (demo-dev, demo-staging, demo-prod)
  02-git-credentials.yaml      # Kargo git credentials Secret (readers add their token here)
  03-warehouse.yaml            # Kargo Warehouse — watches ghcr.io/kargobook/demo-app
  04-stage-dev.yaml
  05-stage-staging.yaml
  06-stage-prod.yaml
configure.sh                   # Replaces kargobook git URLs with reader's fork URL
```

## Container image

`ghcr.io/kargobook/demo-app` — public, pre-built. Readers do NOT need to build anything.
Source: https://github.com/kargobook/demo-app

## configure.sh

Replaces `github.com/kargobook/demo-gitops` with the reader's fork URL in `setup/` files.
Does NOT change the image URL (`ghcr.io/kargobook/demo-app`).

## What NOT to change

- `base/` and `envs/` kustomization files are managed by Kargo promotions. Do not hand-edit
  the `newTag:` values in `envs/*/kustomization.yaml` — Kargo writes those.
- `setup/02-git-credentials.yaml` contains `YOUR_GITHUB_TOKEN` placeholder. Never commit a
  real token here.

## Kargo version

Targets Kargo 1.x. Stage YAML uses the `requestedFreight` API (not the old `subscriptions` API).
