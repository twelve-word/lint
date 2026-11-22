# Twelveword shared lint rules

The lint rules every Twelveword project runs. They catch real bugs only: style, size limits and import order stay with each project's own formatter and config.

| File | Holds |
|---|---|
| `ruff.toml` | The Python rules (Ruff) |
| `ruff-version` | The one Ruff version that runs them |
| `eslint.config.mjs` | The TypeScript and JavaScript rules, added on top of the project's own ESLint config |
| `.pre-commit-hooks.yaml` | The pre-commit hooks `twelveword-lint-python` and `twelveword-lint-ts-js` |

This repository is public so that CI can fetch it. It holds no project code and no secrets.

## Use it in pre-commit

Pin a commit, never a branch, so a change here cannot change another project's checks without that project's own PR:

```yaml
- repo: https://github.com/twelve-word/lint
  rev: <commit SHA>
  hooks:
    - id: twelveword-lint-python
    - id: twelveword-lint-ts-js
```

The Python hook needs `uv` on the path. The ESLint hook uses the project's installed ESLint, and skips a project that has none.

## Where else it runs

The `core` plugin in the private `twelve-word/common-plugins` repository runs the same rules on each file that Claude Code edits. It pins a commit of this repository in `plugins/core/lint/rules-commit`.

## Change a rule

`CLAUDE.md` has the steps. In short: change the rule, add a fixture line that breaks it, and run `make check`, which proves that every rule still catches its fixture. After the PR merges, move the pin in `common-plugins`, then the `rev` in each project in its own PR.
