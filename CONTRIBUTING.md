# Contributing

We welcome contributions to osapi-justfiles. Read this document before you send
a PR. It gives the prerequisites, the setup, the conventions for recipes, and
the pull request workflow.

## Before you start

- Read the [Code of Conduct](CODE_OF_CONDUCT.md). It applies to all
  communication in this repository.

- **Design documents.** The design of this repository is in
  [osapi-io/specs](https://github.com/osapi-io/specs) under
  `components/osapi-justfiles/`. Read it before you change the behavior. When
  you change the behavior, change the design too. A design document in this
  repository becomes old when the code changes, and nothing finds the
  difference.

- **Examine the work that exists.** Look for a PR or an issue about the change
  that you want to make. If you find one, use what it says in your work.

- **Backwards compatibility.** All repositories in the organization download
  these files from `main`. Thus a breaking change breaks all of them at the same
  time. A change that is backwards compatible is much more likely to be merged.
  If your change cannot be backwards compatible, open an issue first. Then we
  can discuss the migration before you write a PR.

## Prerequisites

- **[just].** The task runner. Install it with `brew install mise` and let mise
  supply it. Alternatively, install it with `brew install just`.

Each module needs the tools that it runs. `md` needs [uv]. `go` needs a Go
toolchain. The README of each module lists what that module needs.

### Claude Code

If you use [Claude Code] to write changes, install this plugin from the default
marketplace:

```
/plugin install commit-commands@claude-plugins-official
```

- **commit-commands.** Gives the `/commit` and `/commit-push-pr` slash commands.
  These commands follow the commit conventions of this repository.

**Design is done in the design documents.** Write or change the page in
[osapi-io/specs](https://github.com/osapi-io/specs) before you build. Correct
the page where the build shows that it is wrong. A design document in this
repository becomes old when the code changes, and nothing finds the difference.

## Making changes

Edit the `.just` files. To test a change before it is merged, change the `fetch`
recipe of a consumer to download from your branch:

```bash
curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/your-branch/md/md.just -o .just/remote/md.just
```

Then run the recipes of that consumer to make sure that the behavior is correct.
You can test a shared recipe only against a real consumer.

`raw.githubusercontent.com` keeps a cached copy for some minutes. Thus after the
merge, the CI of a consumer can download the previous version. If this occurs,
run the CI again. Do not think that the change is broken.

## Recipe conventions

### Style

- Put a `#` comment above each recipe. The comment is the description of the
  recipe.
- The group of a recipe is its prefix. The name of each recipe in a file starts
  with the prefix of the file. Each recipe has the `[group('prefix')]` that
  agrees with it: `go-test` is in `go`, and `docs-start` is in `docs`. Then
  `just --list` shows one block for each tool, and the name of a recipe tells
  you its group.
- Use `[private]` for a helper recipe that a person must not call directly.
- Use kebab-case for recipe names (`fmt-check`, `unit-cov`).
- Use a `#!/usr/bin/env bash` shebang for a shell block that has more than one
  line.
- Write parameters in just syntax: `recipe param:`, not as shell arguments.

### Variables

- Use `env("VAR", "default")` for a value that the user can change.
- Use a backtick expression for a value that comes from the shell, for example
  `` git_root := `git rev-parse --show-toplevel` ``.
- **Start the name of each environment variable with `JUST_`**, for example
  `JUST_MAIN_PACKAGE`. The `justfiles` specification makes this a requirement.

An imported module shares one namespace with the justfile of the consumer. Thus
also start the name of each module variable with the module name. A general name
such as `wrap` replaces each other `wrap` in scope, and gives no error.

### Dependencies between recipes

- Use the just syntax for dependencies: `recipe: dep1 dep2`.
- The `test` recipe of a module must run all of its checks.
- Where possible, make each recipe so that it can run alone.

### License header

Each `.just` file must start with the MIT license header, as `#` comments, with
the year 2026.

## Before committing

```bash
just test
```

This command makes sure that each justfile in the repository has the canonical
format. CI runs the same check. `just ready` corrects the format.

## Branching

Make all changes on a feature branch. Create the branch from `main`. Use the
name `type/short-description`, where `type` is the [Conventional Commits] type:

- `feat/add-docs-recipe`
- `fix/coverage-path`
- `chore/update-deps`

If you are on `main` when you use the `/commit` command of Claude Code, the
command creates a branch.

## Commit messages

Follow [Conventional Commits] with the 50/72 rule:

- The subject line has a maximum of 50 characters, the imperative mood, a
  capital letter at the start, and no period.
- The body wraps at 72 characters. A blank line separates it from the subject.
- The format is `type(scope): description`.
- The types are `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, and
  `chore`.
- Say what changed and why. Do not say how.

Write commit messages that give useful information. Do not put too many commits
on a PR. Usually a PR has one commit. A large PR can have some commits. Use git
squash and rebase to decrease the number of commits.

## Submitting a PR

- **Describe your changes.** Say what changed and why. A reviewer must not have
  to read the diff to find the reason.
- **Issue and PR links.** Link to the previous work, for example related issues
  or PRs. Say how your changes are different from that work or add to it.
- **Name the consumers that you used for the test.** If no real consumer ran a
  shared recipe, the recipe is not tested.
- **Draft PRs.** If your changes are not complete and you want to discuss them,
  open the PR as a draft. Then add a comment to start the discussion. Use
  comments, not the PR description, for the discussion. Then you can change the
  description later, and the discussion stays.

## AI usage

The [AI Usage Policy](AI_POLICY.md) applies to all contributions. Say which tool
you used. Make sure that you can explain what your change does without help from
AI tools.

## FAQ

> I want to contribute, where do I start?

We welcome all types of contributions, for example a typo fix or a new recipe.
You can also vote on issues, comment on issues, or help to answer questions.

> I'm stuck, where can I get help?

If you have questions, open a [Discussion] on GitHub.

[claude code]: https://claude.ai/code
[conventional commits]: https://www.conventionalcommits.org
[discussion]: https://github.com/osapi-io/osapi-justfiles/discussions
[just]: https://just.systems
[uv]: https://docs.astral.sh/uv/
