#!/usr/bin/env bash
# Pre-commit entry point for the shared ESLint rules. Pre-commit passes the changed TS/JS files
# as arguments. Each file lints through the nearest eslint.config.* above it, the same walk the
# Claude Code lint hook does, so a monorepo with several frontends still finds each one's own
# installed ESLint. A file whose project has neither is skipped.
# Each project runs ESLint once for all its files. One ESLint start costs seconds, so one run per
# file made `pre-commit run --all-files` take minutes on a repo with a few hundred files.
set -uo pipefail

lint_dir="$(cd "$(dirname "$0")" && pwd)"
status=0
# Bash 3.2, the macOS default, has no associative arrays, so the lookups are parallel lists.
# projects[i] and configs[i] describe one project, and the file $lists/i holds its files.
# dirs[j] is a directory already walked, and dir_projects[j] its project index, or -1 for none.
projects=() configs=() dirs=() dir_projects=()
lists=$(mktemp -d)
trap 'rm -rf "$lists"' EXIT

# Sets index to the project of directory $1, or to -1 if no usable ESLint is above it.
find_project() {
  local dir=$1 project_dir=$1 project_config="" found=1 parent i
  for i in "${!dirs[@]}"; do
    if [[ ${dirs[$i]} == "$dir" ]]; then
      index=${dir_projects[$i]}
      return
    fi
  done
  while true; do
    if project_config=$(compgen -G "$project_dir/eslint.config.*"); then
      found=0
      break
    fi
    parent=${project_dir%/*}
    [[ -z $parent || $parent == "$project_dir" ]] && break
    project_dir=$parent
  done
  index=-1
  if [[ $found -eq 0 && $project_config != *$'\n'* && -x "$project_dir/node_modules/.bin/eslint" ]]; then
    for i in "${!projects[@]}"; do
      [[ ${projects[$i]} == "$project_dir" ]] && index=$i && break
    done
    if [[ $index -lt 0 ]]; then
      index=${#projects[@]}
      projects+=("$project_dir")
      configs+=("$project_config")
    fi
  fi
  dirs+=("$dir")
  dir_projects+=("$index")
}

for file in "$@"; do
  [[ $file == /* ]] || file="$PWD/$file"
  [[ $file == */* ]] || continue
  find_project "${file%/*}"
  [[ $index -ge 0 ]] && printf '%s\0' "$file" >>"$lists/$index"
done

for i in "${!projects[@]}"; do
  (cd "${projects[$i]}" && ESLINT_PROJECT_CONFIG="${configs[$i]}" xargs -0 \
    node_modules/.bin/eslint -c "$lint_dir/eslint.config.mjs" --quiet --no-warn-ignored \
    <"$lists/$i") || status=1
done

exit $status
