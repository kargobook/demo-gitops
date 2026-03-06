# setup/

One-time cluster setup resources for Chapter 6. Apply these in order after
forking this repo and adding your GitHub token to `02-git-credentials.yaml`.

Argo CD only watches `base/` and `envs/` — it ignores this directory.

## Apply order

```bash
kubectl apply -f setup/00-namespaces.yaml
kubectl apply -f setup/01-argocd-apps.yaml
kubectl apply -f setup/02-git-credentials.yaml   # add your token first
kubectl apply -f setup/03-warehouse.yaml
kubectl apply -f setup/04-stage-dev.yaml
kubectl apply -f setup/05-stage-staging.yaml
kubectl apply -f setup/06-stage-prod.yaml
```
