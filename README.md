# demo-gitops

GitOps configuration repository for **_Kargo in Action_** (Manning). When Kargo pins a new image digest, it updates the environment's Helm values file in this repo, and Argo CD syncs the change into the cluster.

This repo backs two parts of the book.

## Chapter 3: Getting started (the `demo-app` walkthrough)

A single service, `demo-app`, promoted through `dev → pre-prod → prod`. This is the content you fork/clone in chapter 3.

```
charts/demo-app/            # the demo-app Helm chart
envs/{dev,pre-prod,prod}/    # per-environment values.yaml (Kargo writes the image tag and digest here)
setup/                      # Kargo Project, Warehouse, Stages + the Argo CD ApplicationSet
configure.sh                # helper to point the setup at your fork
```

Kargo's `yaml-update` step writes to `envs/<env>/values.yaml`, and each Argo CD Application renders `charts/demo-app` with its environment's values file.

## Chapters 4 and 7: Scaling across services (`payments` + `auth`)

Two coordinated services demonstrating the multi-service patterns. Chapter 4's coordinated pre-prod Stage and chapter 7's multi-service examples both use `apps/payments` and `apps/auth`.

```
charts/{payments-api,auth-service}/          # one Helm chart per service
apps/{payments,auth}/envs/{dev,pre-prod,prod}/  # per-environment values.yaml
argocd/                     # one Argo CD Application per service/environment
kargo/                      # Kargo Project, Warehouses, and Stages for both services
```

- **dev** and **pre-prod**: auto-promotion enabled
- **prod**: manual promotion required

## Related repositories

- [demo-app](https://github.com/kargobook/demo-app): the `demo-app` sample image
- [payments-api](https://github.com/kargobook/payments-api), [auth-service](https://github.com/kargobook/auth-service): chapter 7 sample services
- [kargo-in-action](https://github.com/kargobook/kargo-in-action): the book's chapter-by-chapter example listings

## License

MIT
