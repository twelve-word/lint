#!/usr/bin/env bash
# Pre-commit entry point for the shared Ruff rules. Pre-commit passes the changed Python files as
# arguments. ruff.toml and ruff-version live next to this script, so every repo gets the same
# rules and the same Ruff with nothing copied into the repo's own config.
set -uo pipefail

lint_dir="$(cd "$(dirname "$0")" && pwd)"
ruff_version=$(<"$lint_dir/ruff-version")
uvx --quiet "ruff@$ruff_version" check --config "$lint_dir/ruff.toml" --force-exclude "$@"
