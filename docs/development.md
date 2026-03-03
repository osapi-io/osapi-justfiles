# Development

This guide covers the tools, setup, and conventions needed to work on
osapi-justfiles.

## Prerequisites

- **[just][]** — Task runner. Install with `brew install just`.

### Claude Code

If you use [Claude Code][] for development, install these plugins from the
default marketplace:

```
/plugin install commit-commands@claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

- **commit-commands** — provides `/commit` and `/commit-push-pr` slash commands
  that follow the project's commit conventions automatically.
- **superpowers** — provides structured workflows for planning, TDD, debugging,
  code review, and git worktree isolation.

## Making Changes

Edit the `.just` files directly. To test changes, point a consuming project's
`fetch` recipe at your local branch:

```bash
curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/your-branch/go.just -o .just/remote/go.just
```

Then run the consuming project's recipes to verify behavior.

## Branching

All changes should be developed on feature branches. Create a branch from `main`
using the naming convention `type/short-description`, where `type` matches the
[Conventional Commits][] type:

- `feat/add-docs-recipe`
- `fix/coverage-path`
- `chore/update-deps`

When using Claude Code's `/commit` command, a branch will be created
automatically if you are on `main`.

## Commit messages

Follow [Conventional Commits][] with the 50/72 rule:

- **Subject line**: max 50 characters, imperative mood, capitalized, no period
- **Body**: wrap at 72 characters, separated from subject by a blank line
- **Format**: `type(scope): description`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- Summarize the "what" and "why", not the "how"

Try to write meaningful commit messages and avoid having too many commits on a
PR. Most PRs should likely have a single commit (although for bigger PRs it may
be reasonable to split it in a few). Git squash and rebase is your friend!

[just]: https://just.systems
[Claude Code]: https://claude.ai/code
[Conventional Commits]: https://www.conventionalcommits.org
