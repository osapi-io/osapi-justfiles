# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Shared [just](https://just.systems/) recipes used by osapi-io projects via
[just modules](https://just.systems/man/en/modules.html). Consuming projects
use `mod` directives pointing at shim files (`*.mod.just`) which set the
working directory and import the actual recipe files. Both shim and recipe
files are fetched via a `fetch` recipe.

## Development Reference

- @docs/development.md - Prerequisites, setup, conventions, commits
- @docs/contributing.md - PR workflow and contribution guidelines

## Repository Structure

- `go.just` - Go build, test, lint, and formatting recipes
- `go.mod.just` - Module shim for go.just (sets working directory to project root)
- `bats.just` - BATS integration test recipes
- `bats.mod.just` - Module shim for bats.just (sets working directory to `test/`)
- `docs.just` - Docusaurus documentation recipes
- `docs.mod.just` - Module shim for docs.just (sets working directory to `docs/`)

## Conventions

### Recipe Style

- Use `#` comment above each recipe as its description
- Use `[group: 'name']` attributes to organize recipes (setup, test, fmt, lint, dev, build, codegen, docs)
- Use `[private]` for helper recipes not meant to be called directly
- Use kebab-case for recipe names (e.g., `fmt-check`, `unit-cov`)
- Use `#!/usr/bin/env bash` shebang for multi-line shell blocks
- Parameters use just syntax: `recipe param:` not shell args

### Variables

- Use `env("VAR", "default")` for user-configurable values
- Use backtick expressions for shell-derived values (e.g., `` git_root := `git rev-parse --show-toplevel` ``)
- Prefix env vars with `JUST_` to avoid collisions (e.g., `JUST_MAIN_PACKAGE`)

### License Header

All `.just` files must include the MIT license header at the top using `#` comments with year 2026.

### Dependencies Between Recipes

- Use just dependency syntax: `recipe: dep1 dep2`
- The `test` recipe should chain all checks (mod, fmt-check, vet, unit-cov)
- Keep recipes independently runnable where possible

### Branching

When committing changes via `/commit`, create a feature branch first if
currently on `main`. Branch names use the pattern `type/short-description`
(e.g., `feat/add-dns-retry`, `fix/memory-leak`, `docs/update-readme`).

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) with the
50/72 rule:

- **Format**: `type(scope): description`
- **Subject line**: max 50 characters, imperative mood, capitalized, no period
- **Body**: wrap at 72 characters, separated from subject by a blank line
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

When committing via Claude Code, end with:
- `🤖 Generated with [Claude Code](https://claude.ai/code)`
- `Co-Authored-By: Claude <noreply@anthropic.com>`

Example:

    feat(go): add init recipe for tool dependencies

    Add a recipe that runs `go get -tool` for all required tool
    dependencies, making it easy to bootstrap a new project's go.mod.

    🤖 Generated with [Claude Code](https://claude.ai/code)
    Co-Authored-By: Claude <noreply@anthropic.com>

### Task Tracking

Implementation planning and execution uses the superpowers plugin workflows
(`writing-plans` and `executing-plans`). Plans live in `docs/plans/`.

### Parity with Taskfiles

These recipes mirror `osapi-taskfiles/`. When updating recipes here, consider
whether the corresponding taskfile needs the same change. Recipe name mapping:

| Taskfile | Justfile |
|---|---|
| `go:test` | `test` |
| `go:unit` | `unit` |
| `go:unit:cov` | `unit-cov` |
| `go:vet` | `vet` |
| `go:fmt` | `fmt` |
| `go:fmt:check` | `fmt-check` |
| `bats:test` | `test` |
| `docs:start` | `start` |
