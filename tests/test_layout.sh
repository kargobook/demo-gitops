#!/usr/bin/env bash
# Every Application renders with its own values file; no Kustomize remains.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
if git ls-files | grep -q 'kustomization.yaml$'; then echo "FAIL: kustomization.yaml remains"; fail=1; fi
for f in setup/argocd/applicationset.yaml argocd/*.yaml; do
  while IFS=$'\t' read -r name path vf; do
    [[ "$path" == charts/* ]] || { echo "FAIL: $f $name path $path"; fail=1; continue; }
    helm template "$name" "$path" -f "$path/$vf" >/dev/null || { echo "FAIL: $f $name render"; fail=1; }
  done < <(python3 - "$f" <<'PY'
import sys, yaml
def emit(name, source):
    vf = ((source.get("helm") or {}).get("valueFiles") or ["-"])[0]
    print(name, source.get("path", "-"), vf, sep="\t")
for d in yaml.safe_load_all(open(sys.argv[1])):
    if not d:
        continue
    if d.get("kind") == "Application":
        emit(d["metadata"]["name"], d["spec"]["source"])
    elif d.get("kind") == "ApplicationSet":
        tmpl = yaml.dump(d["spec"]["template"])
        for gen in d["spec"]["generators"]:
            for el in (gen.get("list") or {}).get("elements", []):
                rendered = tmpl
                for k, v in el.items():
                    rendered = rendered.replace("{{" + k + "}}", str(v))
                t = yaml.safe_load(rendered)
                emit(t["metadata"]["name"], t["spec"]["source"])
PY
)
done
if grep -rq 'kustomize-set-image' setup kargo; then echo "FAIL: kustomize-set-image in setup/ or kargo/"; fail=1; fi
for pair in "auth-prod charts/auth-service apps/auth/envs/prod/values.yaml" "payments-prod charts/payments-api apps/payments/envs/prod/values.yaml"; do
  read -r rel chart vf <<<"$pair"
  helm template "$rel" "$chart" -f "$vf" | grep -q 'replicas: 3$' || { echo "FAIL: $rel must render replicas: 3"; fail=1; }
done
bash tests/test_charts.sh || fail=1
exit $fail
