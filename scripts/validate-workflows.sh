#!/usr/bin/env bash
set -euo pipefail

workflow_dir=.github/workflows

# Known Node.js 20-era action majors that caused warnings in the release run.
if grep -R -nE 'actions/(checkout|cache|upload-artifact|download-artifact)@v4([^-0-9.]|$)' "$workflow_dir"; then
  echo 'Deprecated GitHub Action major detected; use the current pinned versions.' >&2
  exit 1
fi

# Rust installation/cache must be owned by the maintained Rust setup action.
grep -q 'actions-rust-lang/setup-rust-toolchain@v1.17.0' "$workflow_dir/reusable-rust.yml"
if grep -q 'uses: actions/cache@' "$workflow_dir/reusable-rust.yml"; then
  echo 'Do not add a second generic Cargo cache; setup-rust-toolchain already manages Rust caching.' >&2
  exit 1
fi

# Reusable Rust must never checkout packages into a component workspace.
if grep -q 'repository: Unetic/packages' "$workflow_dir/reusable-rust.yml"; then
  echo 'Double checkout of Unetic/packages detected in reusable-rust.yml.' >&2
  exit 1
fi

# A GitHub release created with a new tag emits a tag push as well. Keep one automatic trigger only.
if grep -Eq '^[[:space:]]+release:[[:space:]]*$|types:[[:space:]]*\[published\]' "$workflow_dir/release.yml"; then
  echo 'packages release.yml must not listen to release.published; tag push is the single automatic trigger.' >&2
  exit 1
fi

# Angular production dist is built once in the reusable web release path.
count=$(grep -c 'npm run build' "$workflow_dir/reusable-web.yml" || true)
if [ "$count" -ne 1 ]; then
  echo "Expected exactly one npm run build in reusable-web.yml, found $count" >&2
  exit 1
fi

echo 'Workflow modernization rules are valid'
