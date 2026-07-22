#!/usr/bin/env bash
# Terraform validation script
set -euo pipefail
echo "Validating Terraform..."
for dir in $(find . -name "*.tf" -exec dirname {} \; | sort -u); do
  (cd "$dir" && terraform fmt -check && terraform validate)
  echo "  ✓ $dir"
done
echo "All Terraform validations passed."
