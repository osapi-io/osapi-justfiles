# Contributing

Contributions to osapi-justfiles are very welcome, but we ask that you read this
document before submitting a PR. It covers everything you need: prerequisites,
setup, the conventions recipes follow, and the pull request workflow.

## Before you start

- Read the [Code of Conduct](CODE_OF_CONDUCT.md). It applies to every
  interaction in this repo.

- **Design docs.** How this repository is built is documented in
  [osapi-io/specs](https://github.com/osapi-io/specs) under
  `components/osapi-justfiles/`. Read it before changing behaviour, and change
  it when you do. A design doc kept in this repository goes stale the moment the
  code moves past it, and nothing catches the drift.

- **Check existing work.** Is there an existing PR? Are there issues discussing
  the change you want to make? Please make sure you consider/address these
  discussions in your work.

- **Backwards compatibility.** Every repository in the organization fetches
  these files from `main`, so a breaking change breaks them all at once. It is
  much more likely that your change will be merged if it is backwards
  compatible. If it cannot be, consider opening an issue first so the migration
  can be discussed before you invest your time in a PR.

## Prerequisites

- **[just].** Task runner. Install with `brew install mise` and let mise provide
  it, or `brew install just` directly.

Individual modules require the tools they invoke. `md` needs [uv]; `go` needs a
Go toolchain. Each module's README lists its own requirements.

### Claude Code

If you use [Claude Code] for development, install this plugin from the default
marketplace:

```
/plugin install commit-commands@claude-plugins-official
```

- **commit-commands.** provides `/commit` and `/commit-push-pr` slash commands
  that follow the project's commit conventions automatically.

**Design happens in the design docs.** Write or change the page in
[osapi-io/specs](https://github.com/osapi-io/specs) before building, and correct
it where building proves it wrong. A design document kept in this repository
goes stale the moment the code moves past it, and nothing catches the drift.

## Making changes

Edit the `.just` files directly. To test a change before it is merged, point a
consuming project's `fetch` recipe at your branch:

```bash
curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/your-branch/md/md.just -o .just/remote/md.just
```

Then run that project's recipes to verify the behavior. There is no way to test
a shared recipe except against a real consumer.

Note that `raw.githubusercontent.com` caches for several minutes. After merging,
a consumer's CI can still fetch the previous version. Re-run it rather than
assuming the change is broken.

## Recipe conventions

### Style

- Use a `#` comment above each recipe as its description.
- Use `[group('name')]` attributes to organize recipes (setup, test, fmt, lint,
  dev, build, codegen, docs).
- Use `[private]` for helper recipes not meant to be called directly.
- Use kebab-case for recipe names (`fmt-check`, `unit-cov`).
- Use a `#!/usr/bin/env bash` shebang for multi-line shell blocks.
- Parameters use just syntax: `recipe param:`, not shell arguments.

### Variables

- Use `env("VAR", "default")` for user-configurable values.
- Use backtick expressions for shell-derived values, e.g.
  `` git_root := `git rev-parse --show-toplevel` ``.
- **Prefix every environment variable with `JUST_`**, e.g. `JUST_MAIN_PACKAGE`.
  This is a requirement of the `justfiles` specification, not a preference.

Modules consumed by import share one namespace with the consuming justfile, so
prefix their variables with the module name as well. A generic name like `wrap`
silently overwrites any other `wrap` in scope.

### Dependencies between recipes

- Use just dependency syntax: `recipe: dep1 dep2`.
- A module's `test` recipe should chain all of its checks.
- Keep recipes independently runnable where possible.

### License header

All `.just` files must include the MIT license header at the top, as `#`
comments, with year 2026.

## Before committing

```bash
just test
```

This checks that every justfile in the repository is canonically formatted,
which is what CI runs. `just ready` fixes formatting.

## Branching

All changes should be developed on feature branches. Create a branch from `main`
using the naming convention `type/short-description`, where `type` matches the
[Conventional Commits] type:

- `feat/add-docs-recipe`
- `fix/coverage-path`
- `chore/update-deps`

When using Claude Code's `/commit` command, a branch will be created
automatically if you are on `main`.

## Commit messages

Follow [Conventional Commits] with the 50/72 rule:

- **Subject line**: max 50 characters, imperative mood, capitalized, no period
- **Body**: wrap at 72 characters, separated from subject by a blank line
- **Format**: `type(scope): description`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- Summarize the "what" and "why", not the "how"

Try to write meaningful commit messages and avoid having too many commits on a
PR. Most PRs should likely have a single commit (although for bigger PRs it may
be reasonable to split it in a few). Git squash and rebase is your friend!

## Submitting a PR

- **Describe your changes.** Say what changed and why. A reviewer should not
  have to read the diff to learn the reason for it.
- **Issue/PR links.** Link any previous work such as related issues or PRs.
  Please describe how your changes differ to/extend this work.
- **Name the consumers you tested against.** a shared recipe that was never run
  by a real project has not been tested.
- **Draft PRs.** If your changes are incomplete, but you would like to discuss
  them, open the PR as a draft and add a comment to start a discussion. Using
  comments rather than the PR description allows the description to be updated
  later while preserving any discussions.

## AI usage

All contributions are subject to the [AI Usage Policy](AI_POLICY.md). Disclose
the tool you used, and make sure you can explain what your change does without
the aid of AI tools.

## FAQ

> I want to contribute, where do I start?

All kinds of contributions are welcome, whether it's a typo fix or a shiny new
recipe. You can also contribute by upvoting/commenting on issues or helping to
answer questions.

> I'm stuck, where can I get help?

If you have questions, open a [Discussion] on GitHub.

[claude code]: https://claude.ai/code
[conventional commits]: https://www.conventionalcommits.org
[discussion]: https://github.com/osapi-io/osapi-justfiles/discussions
[just]: https://just.systems
[uv]: https://docs.astral.sh/uv/
