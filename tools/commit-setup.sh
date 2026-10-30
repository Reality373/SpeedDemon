#!/usr/bin/env bash
# Run from a terminal with writable .git metadata to commit the prepared workspace.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

if git rev-parse --verify HEAD >/dev/null 2>&1; then
    printf '%s\n' 'Repository already has commits; use normal incremental commits instead.' >&2
    exit 1
fi
git var GIT_AUTHOR_IDENT >/dev/null
git init -b master
if [[ "$(git symbolic-ref --short HEAD)" != master ]]; then
    printf '%s\n' 'Run this setup on master; no branches will be switched automatically.' >&2
    exit 1
fi
if ! git diff --cached --quiet; then
    printf '%s\n' 'Existing staged changes found; review them before running this script.' >&2
    exit 1
fi

git add -- .gitignore tools/commit-setup.sh
git commit -m "chore: configure repository ignores and initial commit workflow"

git add -- resources/upstream/speed-demon-starter
git commit -m "vendor: preserve official Speed Demon starter snapshot"

git add -- resources/upstream/speed-demon-2026 resources/upstream-manifest.json resources/datasets.json
git commit -m "vendor: pin official specs generators references and harness"

git add -- docs/context.md docs/project-brief.md
git commit -m "docs: preserve organizer context and project brief"

git add -- README.md docs/PRD.md docs/architecture.md docs/decisions.md \
    docs/experiment-template.md docs/harness.md docs/problems.md docs/progress.md \
    docs/research.md docs/resources.md docs/status.md docs/testing.md \
    benchmarks/README.md benchmarks/experiments.csv data/README.md results/README.md \
    tests/README.md tools/README.md
git commit -m "docs: define requirements architecture harness plan and progress tracking"

git add -- results/setup
git commit -m "test: record resource integrity reference checks and setup evidence"

git log --oneline -6
git status --short
