# Contributing

Thank you for your contribution to osapi-justfiles.

## Before you start

- Read the [Code of Conduct](CODE_OF_CONDUCT.md). It applies to all
  communication in this repository.
- **Design pages.** The design pages of this repository are in
  [osapi-io/specs](https://github.com/osapi-io/specs), under
  `components/osapi-justfiles/`. Read them before you change the behavior. When
  you change the behavior, change the design page in the same work. A design
  page in this repository becomes incorrect when the code changes. No check
  finds the difference.
- **Examine the work that exists.** Look for a pull request or an issue about
  the change. If you find one, use what it says in your work.
- **Backward compatibility.** Make sure that your change does not stop a program
  that uses osapi-justfiles. All repositories in the organization download these
  files from `main`. Thus a change that breaks compatibility breaks all of them
  at the same time. A change that keeps compatibility is more likely to merge.
  If your change cannot keep it, open an issue first. Then the maintainers can
  discuss the API change before you do the work.

## Prerequisites

Install the tools with [mise]:

```bash
mise install
```

- **[uv].** A Python package runner. `just md-fmt` uses it to run [mdformat]. It
  installs nothing into the repository.
- **[just].** The task runner. Use it to build, test and format. If you do not
  use mise, install just with `brew install just`.

A consumer needs the tools that each module it imports runs. `md` needs [uv].
`go` needs a Go toolchain. The README of each module lists the tools that the
module needs.

### Coding agents

This repository works with any coding agent that reads `AGENTS.md`. `CLAUDE.md`
only points to `AGENTS.md`. Prepare your agent as its documentation tells you.
This repository does not need a plugin or an extension.

## Making changes

Edit the `.just` files. To test a change before it merges, change the `fetch`
recipe of a consumer to download from your branch:

```bash
curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/your-branch/md/md.just -o .just/remote/md.just
```

Then run the recipes of that consumer to make sure that the behavior is correct.

Note: you can test a shared recipe only against a real consumer.

`raw.githubusercontent.com` keeps a cached copy for some minutes. Thus after the
merge, the CI of a consumer can download the previous version. This does not
show that the change is broken. If this occurs, run the CI of the consumer
again.

## Recipe conventions

### Style

- Put a `#` comment above each recipe. The comment is the description of the
  recipe.
- Start the name of each recipe in a file with the prefix of the file. Give each
  recipe the `[group('prefix')]` of that prefix: `go-test` is in `go`, and
  `docs-start` is in `docs`. Then `just --list` shows one block for each tool.
  The name of a recipe also tells you its group.
- Use `[private]` for a helper recipe that a person must not call directly.
- Use kebab-case for recipe names (`fmt-check`, `unit-cov`).
- Use a `#!/usr/bin/env bash` shebang for a shell block that has more than one
  line.
- Write parameters in just syntax: `recipe param:`, not as shell arguments.

### Variables

- Put each value that a consumer can change in a module variable, for example
  `go_coverage_target`. A consumer sets `allow-duplicate-variables` and assigns
  the variable again. The README of each module shows this.
- Use a backtick expression for a value that comes from the shell, for example
  `` git_root := `git rev-parse --show-toplevel` ``.
- Do not read environment variables with `env()`. A module variable is the one
  way to change a value, so a reader finds every setting in the justfile.

An imported module shares one namespace with the justfile of the consumer. Thus
start the name of each module variable with the module name. If two modules use
a general name such as `wrap`, one value replaces the other. just gives no
error.

### Dependencies between recipes

- Use the just syntax for dependencies: `recipe: dep1 dep2`.
- The `test` recipe of a module must run all of its checks.
- Where possible, make each recipe so that it can run alone.

### License header

Each `.just` file must start with the MIT license header, as `#` comments, with
the year 2026.

### Documentation

[mdformat] formats the markdown files, through `uvx`. CI makes sure that the
format is correct.

```bash
just md-fmt-check   # Check formatting
just md-fmt         # Auto-fix formatting
```

Write each page in Simplified Technical English, as
[the osapi-io constitution](https://github.com/osapi-io/specs/blob/main/CONSTITUTION.md)
requires.

## Before you commit

Run `just ready` before you commit. It makes sure that the format of each
justfile and each markdown file is correct:

```bash
just ready
```

`just test` checks the same format and changes no file. CI runs the justfile
format check.

## Branches

Make all changes on a branch. Make the branch from `main`. Give it the name
`type/short-description`, where `type` is the [Conventional Commits] type:

- `feat/add-retry-logic`
- `fix/null-pointer-crash`
- `docs/update-api-reference`
- `refactor/simplify-handler`
- `chore/update-dependencies`

## Commit messages

Use [Conventional Commits] with the 50/72 rule:

- **Subject line.** 50 characters or fewer, in the imperative mood, with no
  period at the end.
- **Body.** Wrap it at 72 characters. Put a blank line between the subject and
  the body.
- **Format.** `type(scope): description`.
- **Types.** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
  `chore`.
- Tell what changed and why, not how.

Write commit messages that help the reader. Keep the number of commits in a pull
request small. Most pull requests have one commit. A large pull request can have
a few. Use squash and rebase to combine commits.

## Submit a pull request

- **Describe your changes.** Tell what changed and why. Then a reviewer does not
  have to read the diff to find the reason.
- **Links to issues and pull requests.** Link to related issues and pull
  requests. Tell how your change is different from that work, or how it adds to
  it.
- **Examples.** Add examples or screenshots that show the effect of your change.
- **Consumers.** Name the consumers that ran your change. If no real consumer
  ran a shared recipe, the recipe is not tested.
- **Draft pull requests.** If your change is not complete but you want to
  discuss it, open the pull request as a draft. Start the discussion in a
  comment, not in the description. Then you can change the description later and
  keep the discussion.

## AI usage

We write this repository with the help of AI tools. The
[AI Usage Policy](AI_POLICY.md) applies to all contributions. Tell which tool
you used. Make sure that you can explain what your change does without the help
of an AI tool.

## FAQ

> I want to contribute. Where do I start?

All contributions are welcome, from a typo fix to a new feature. You can also
vote or comment on issues, or help answer questions.

> I need help. Where do I ask?

Open a [Discussion] on GitHub.

[conventional commits]: https://www.conventionalcommits.org
[discussion]: https://github.com/osapi-io/osapi-justfiles/discussions
[just]: https://just.systems
[mdformat]: https://pypi.org/project/mdformat/
[mise]: https://mise.jdx.dev
[uv]: https://docs.astral.sh/uv/
