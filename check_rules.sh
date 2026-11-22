#!/usr/bin/env bash
# Prove that the shared rules still catch what they are for. Each fixture that breaks the rules
# must get every expected finding, and each fixture that follows them must get none. Run it with
# `make check`. It needs uv, and the packages of fixtures/ts (pnpm -C fixtures/ts install).
set -uo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
ts_dir="$repo_dir/fixtures/ts"
ruff_version=$(<"$repo_dir/ruff-version")
failures=0

EXPECTED_RUFF_CODES=(B006 BLE001 S110 TRY002 ASYNC251 DTZ005 PGH004 E722)
EXPECTED_ESLINT_RULES=(
  @typescript-eslint/no-explicit-any
  eqeqeq
  no-empty
  @typescript-eslint/ban-ts-comment
  no-restricted-globals
)

ruff_codes() {
  uvx --quiet "ruff@$ruff_version" check --config "$repo_dir/ruff.toml" --no-cache \
    --output-format concise --quiet "$1" | sed -nE 's/^[^:]+:[0-9]+:[0-9]+: ([A-Z]+[0-9]+) .*/\1/p' | sort -u
}

eslint_rules() {
  (cd "$ts_dir" && ESLINT_PROJECT_CONFIG="$ts_dir/eslint.config.mjs" \
    node_modules/.bin/eslint -c "$repo_dir/eslint.config.mjs" --no-ignore --format json "$1") |
    python3 -c 'import json, sys; print("\n".join(sorted({m["ruleId"] or "parse-error" for f in json.load(sys.stdin) for m in f["messages"]})))'
}

expect_all() {
  local fixture=$1 found=$2
  shift 2
  for wanted in "$@"; do
    if ! grep -qxF -- "$wanted" <<<"$found"; then
      echo "FAIL: $fixture: the shared rules no longer report $wanted." >&2
      failures=$((failures + 1))
    fi
  done
}

expect_none() {
  local fixture=$1 found=$2
  if [[ -n $found ]]; then
    echo "FAIL: $fixture must pass the shared rules, but got: $(tr '\n' ' ' <<<"$found")" >&2
    failures=$((failures + 1))
  fi
}

expect_all fixtures/python/breaks_every_rule.py \
  "$(ruff_codes "$repo_dir/fixtures/python/breaks_every_rule.py")" "${EXPECTED_RUFF_CODES[@]}"
expect_none fixtures/python/follows_every_rule.py \
  "$(ruff_codes "$repo_dir/fixtures/python/follows_every_rule.py")"
expect_all fixtures/ts/src/components/breaks_every_rule.ts \
  "$(eslint_rules src/components/breaks_every_rule.ts)" "${EXPECTED_ESLINT_RULES[@]}"
expect_none fixtures/ts/src/components/follows_every_rule.ts \
  "$(eslint_rules src/components/follows_every_rule.ts)"
expect_none fixtures/ts/src/api/items.ts "$(eslint_rules src/api/items.ts)"

if ((failures > 0)); then
  echo "$failures check(s) failed." >&2
  exit 1
fi
echo "Every shared rule catches its fixture, and the clean fixtures pass."
