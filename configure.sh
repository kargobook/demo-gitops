#!/usr/bin/env bash
# configure.sh — Substitute placeholder values throughout the example files.
#
# Usage:
#   GITHUB_ORG=my-org GITHUB_USER=my-username bash configure.sh
#
# This replaces the canonical kargobook org/username with your own throughout
# all YAML files in-place. Run once before applying resources or forking.

set -euo pipefail

GITHUB_ORG="${GITHUB_ORG:-}"
GITHUB_USER="${GITHUB_USER:-}"

if [[ -z "$GITHUB_ORG" || -z "$GITHUB_USER" ]]; then
  echo "ERROR: Both GITHUB_ORG and GITHUB_USER must be set."
  echo ""
  echo "  export GITHUB_ORG=your-github-org"
  echo "  export GITHUB_USER=your-github-username"
  echo "  bash configure.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Configuring example files..."
echo "  GITHUB_ORG:  ${GITHUB_ORG}"
echo "  GITHUB_USER: ${GITHUB_USER}"
echo ""

# Only the GitHub git repo URLs change — the image stays at ghcr.io/kargobook/demo-app
# so readers don't need to build or push anything.
find "$SCRIPT_DIR" -name "*.yaml" | while read -r file; do
  sed -i.bak \
    -e "s|github\.com/kargobook/demo-gitops|github.com/${GITHUB_ORG}/demo-gitops|g" \
    -e "s|username: kargobook|username: ${GITHUB_USER}|g" \
    "$file"
  rm -f "${file}.bak"
  echo "  configured: ${file#"$SCRIPT_DIR/"}"
done

echo ""
echo "Done. Next steps:"
echo "  1. Add your GitHub token to setup/02-git-credentials.yaml"
echo "     (replace YOUR_GITHUB_TOKEN — do not commit this file with a real token)"
echo "  3. Apply cluster resources (from the demo-gitops repo root):"
echo "     kubectl apply -f setup/00-namespaces.yaml"
echo "     kubectl apply -f setup/01-argocd-apps.yaml"
echo "     kubectl apply -f setup/02-git-credentials.yaml"
echo "     kubectl apply -f setup/03-warehouse.yaml"
echo "     kubectl apply -f setup/04-stage-dev.yaml"
echo "     kubectl apply -f setup/05-stage-staging.yaml"
echo "     kubectl apply -f setup/06-stage-prod.yaml"
