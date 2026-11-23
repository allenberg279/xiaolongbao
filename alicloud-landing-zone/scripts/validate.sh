#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v terraform >/dev/null 2>&1 || { echo "terraform is required" >&2; exit 1; }
terraform fmt -check -recursive "$ROOT/stacks"
for stack in organization network audit; do
  echo "==> validate: $stack"
  (cd "$ROOT/stacks/$stack" && terraform init -backend=false -input=false -no-color && terraform validate -no-color)
done
