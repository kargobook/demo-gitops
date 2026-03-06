# demo-gitops

Companion GitOps repository for Chapter 6 of *Continuous Promotion with Kargo*
(O'Reilly, 2026).

The container image used by this repo is published at
`ghcr.io/kargobook/demo-app`; you do not need to build or push anything.

## Repository layout

```
base/          Kustomize base manifests (Deployment + Service)
envs/
  dev/         Dev overlay  — Argo CD Application: demo-dev
  staging/     Staging overlay — Argo CD Application: demo-staging
  prod/        Prod overlay — Argo CD Application: demo-prod
setup/         One-time cluster setup resources (not watched by Argo CD)
configure.sh   Substitutes kargobook URLs with your own fork URL
```

## Prerequisites

- A Kubernetes cluster with Kargo and Argo CD installed.
  If you need to set one up locally, see the official docs:
  - [Argo CD installation](https://argo-cd.readthedocs.io/en/stable/getting_started/)
  - [Kargo installation](https://docs.kargo.io/installation/installing-kargo)
- `kubectl` configured against that cluster
- A GitHub personal access token with `public_repo` scope

## Quickstart

### 1. Fork this repo

Fork `kargobook/demo-gitops` to your GitHub account. Kargo needs write access
to push promotion commits, so you must use your own fork.

### 2. Clone your fork

```bash
git clone https://github.com/YOUR_ORG/demo-gitops.git
cd demo-gitops
```

### 3. Configure URLs

```bash
export GITHUB_ORG=your-github-org-or-username
export GITHUB_USER=your-github-username
bash configure.sh
```

This updates the `github.com/kargobook/demo-gitops` references in `setup/` to
point at your fork. The image URL (`ghcr.io/kargobook/demo-app`) is unchanged.

### 4. Add your GitHub token

Edit `setup/02-git-credentials.yaml` and replace `YOUR_GITHUB_TOKEN` with your
personal access token. Do not commit this file with a real token.

### 5. Apply cluster resources

```bash
kubectl apply -f setup/00-namespaces.yaml
kubectl apply -f setup/01-argocd-apps.yaml
kubectl apply -f setup/02-git-credentials.yaml
kubectl apply -f setup/03-warehouse.yaml
kubectl apply -f setup/04-stage-dev.yaml
kubectl apply -f setup/05-stage-staging.yaml
kubectl apply -f setup/06-stage-prod.yaml
```

Verify the Warehouse found the images:

```bash
kubectl get freight -n kargo
```

You should see one Freight object for each tag (`1.0.0` and `1.1.0`).

### 6. Trigger your first promotion

```bash
# Get the freight name, then:
kubectl create -f - <<EOF
apiVersion: kargo.akuity.io/v1alpha1
kind: Promotion
metadata:
  name: promote-dev-v1
  namespace: kargo
spec:
  stage: dev
  freight: <freight-name-from-above>
EOF

kubectl get promotion promote-dev-v1 -n kargo -w
```

When it reaches `Succeeded`, check your fork — Kargo will have pushed a commit
updating `envs/dev/kustomization.yaml` with the new image tag.
