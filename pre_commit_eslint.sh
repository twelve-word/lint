#!/usr/bin/env bash
# Pre-commit entry point for the shared ESLint rules. Pre-commit passes the changed TS/JS files
# as arguments. Each file lints through the nearest eslint.config.* above it, the same walk the
# Claude Code lint hook does, so a monorepo with several frontends still finds each one's own
# installed ESLint. A file whose project has neither is skipped.
set -uo pipefail

lint_dir="$(cd "$(dirname "$0")" && pwd)"
status=0

for file in "$@"; do
  file_abs="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
  project_dir=$(dirname "$file_abs")

  found=1
  while true; do
    if project_config=$(compgen -G "$project_dir/eslint.config.*"); then
      found=0
      break
    fi
    parent=$(dirname "$project_dir")
    [[ $parent == "$project_dir" ]] && break
    project_dir=$parent
  done
  [[ $found -eq 0 ]] || continue
  [[ $project_config == *$'\n'* ]] && continue
  [[ -x "$project_dir/node_modules/.bin/eslint" ]] || continue

  (cd "$project_dir" && ESLINT_PROJECT_CONFIG="$project_config" \
    node_modules/.bin/eslint -c "$lint_dir/eslint.config.mjs" --quiet --no-warn-ignored "$file_abs") \
    || status=1
done

exit $status
