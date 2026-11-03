# setup/

The resources chapter 3 creates, in finished form. The chapter creates them one
at a time with the Argo CD and Kargo CLIs; this directory holds the same files
in one place.

Run `configure.sh` first so every file points at your fork.

- `argocd/applicationset.yaml`: one Argo CD Application per environment, each
  rendering `charts/demo-app` with that environment's `envs/` values file.
- `kargo/`: the `demo` Project, its Warehouse, its three Stages, and the
  ProjectConfig that turns on auto-promotion for dev.

## Starting the pipeline over

Projects and their pipelines are long-lived: you update them from time to
time, but you rarely start one over. If you do want to start this one over,
delete the Project, which deletes everything in it:

```bash
kargo delete project demo
```

Then recreate it with three commands:

```bash
kargo apply --filename setup/kargo/01-project.yaml
kargo create repo-credentials --project demo demo-git-creds --git \
  --repo-url https://github.com/$(gh api user --jq .login)/demo-gitops.git \
  --username $(gh api user --jq .login) --password "$(gh auth token)"
kargo apply --recursive --filename setup/kargo/
```

If the first command says the namespace is still being terminated, wait a few
seconds and run it again.

The Git credentials have to exist before the last command, because
`04-projectconfig.yaml` turns on auto-promotion for dev, and dev's first
promotion pushes to your fork. They are never stored in a file:
`kargo create repo-credentials` builds the Secret from the token `gh auth token`
prints.

Deleting the Project leaves your fork alone, so the values files keep what
Kargo wrote, and `kargo/02-warehouse.yaml` keeps whatever constraint you gave
it.
