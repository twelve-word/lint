# Twelveword shared lint rules

Shared rules for every Twelveword project come from the `twelve-word/common-plugins` plugins, which load at session start. They are the standard here with no exceptions. This file adds this repository's own rules.

Linear: team TWE. No Linear project covers the shared repositories yet: file work for this repository in team TWE with no project.

This repository is public, so that CI in every project can fetch it. Put nothing here that is not lint rules: no project names, no code from a project, no secrets.

## What a rule must be

- A rule catches a real bug, or enforces a decided architecture rule (such as "every backend call goes through `src/api/`"). Style, size limits, type hints and import order stay with each project's own formatter and config.
- Each rule has a reason in a comment next to it, and points to the decision in `GUIDANCE.md` or a stack skill of `common-plugins` when one exists.

## Change a rule

1. Change `ruff.toml` or `eslint.config.mjs`. To move Ruff, change `ruff-version`.
2. Add a line that breaks the new rule to `fixtures/python/breaks_every_rule.py` or `fixtures/ts/src/components/breaks_every_rule.ts`, and add its code to `EXPECTED_RUFF_CODES` or `EXPECTED_ESLINT_RULES` in `check_rules.sh`. Code that follows the rule goes in the matching `follows_every_rule` fixture.
3. Run `make check`. Then remove the rule for a moment and run it again: it must fail. A check that passes either way tests nothing.
4. Open a PR. After it merges, set `plugins/core/lint/rules-commit` in `common-plugins` to the new commit. Each project moves its pre-commit `rev` in its own PR.

## The fixtures

`breaks_every_rule.py` and `breaks_every_rule.ts` break every rule on purpose. The shared rules exclude these two file names, so the edit hook and pre-commit skip them. `check_rules.sh` lints them by name (Ruff) and with `--no-ignore` (ESLint), so the check still sees every finding. Do not rename them, and do not give any other file these names.

`fixtures/ts/` is a stand-in project: its `eslint.config.mjs` plays the project's own config, which the shared rules load and add to.

## Commands

| Command | Does |
|---|---|
| `make install` | Install the TypeScript fixture's packages with pnpm |
| `make check` | What the PR check runs: every rule catches its fixture, and the clean fixtures pass |
