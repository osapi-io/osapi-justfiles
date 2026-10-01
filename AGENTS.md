# AGENTS.md

Test: `just test` | Fix formatting: `just ready`

Read @CONTRIBUTING.md first. It covers prerequisites, how to test a change
against a real consumer, the recipe conventions, and the pull request workflow.
all of which apply to agents exactly as they apply to people. This file carries
only what is specific to agents.

## Running tools

Invoke tools through `mise`, not from your path:

```bash
mise exec -- just test
```

`mise` is active in a person's shell and supplies the versions `.mise.toml`
declares. An agent's shell has no activation, so a bare `just` resolves to
whatever is installed globally, usually an older version.

The symptom is a check that fails here and passes in continuous integration, on
a file nobody edited. When that happens, establish which version ran before
treating the failure as real.

## Where the rules come from

@CONTRIBUTING.md names the specification under "Before you start". When a
convention here and the specification disagree, the specification wins. Say so
rather than following the code.

## A shared recipe cannot be tested here

Nothing in this repository exercises a recipe end to end, so "it looks right" is
not evidence. @CONTRIBUTING.md gives the procedure under "Making changes"; run
it, and say in the PR which consumer you ran.

## Repository structure

| Path                                  | What it is                                                     |
| ------------------------------------- | -------------------------------------------------------------- |
| `<module>/<module>.just`              | A module's recipes, with its own README beside it              |
| `<module>.just` + `<module>.mod.just` | Older shim-based module, documented in the root README         |
| `justfile`                            | This repository's own recipes, which dogfood the `just` module |
| `Dockerfile`, `.dockerignore`         | Publishes every recipe file, flattened, as a scratch image     |

Two consumption styles exist. Both are specified; neither is a mistake to be
corrected on sight.

## Commit trailer

When committing via Claude Code, end the message with:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Task tracking

**Design happens in the design docs.** Write or change the page in
[osapi-io/specs](https://github.com/osapi-io/specs) before building, and correct
it where building proves it wrong. A design document kept in this repository
goes stale the moment the code moves past it, and nothing catches the drift.
