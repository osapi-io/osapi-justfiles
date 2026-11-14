# AGENTS.md

Test: `just test` | Fix formatting: `just ready`

Read @CONTRIBUTING.md first. It gives the prerequisites, the procedure to test a
change against a real consumer, the recipe conventions, and the pull request
workflow. These rules apply to agents the same as they apply to people. This
file has only the rules that are specific to agents.

## Running tools

Run tools through `mise`, not from your path:

```bash
mise exec -- just test
```

`mise` is active in the shell of a person and supplies the versions that
`.mise.toml` declares. The shell of an agent has no activation. Thus a bare
`just` resolves to the version that is installed globally, which is usually
older.

The symptom is a check that fails here and passes in continuous integration, on
a file that nobody changed. When this occurs, find which version ran before you
accept the failure as real.

## Where the rules come from

@CONTRIBUTING.md names the specification under "Before you start". If a
convention here and the specification do not agree, the specification is
correct. Say so. Do not follow the code.

## A shared recipe cannot be tested here

Nothing in this repository runs a recipe from start to end. Thus "it looks
right" is not evidence. @CONTRIBUTING.md gives the procedure under "Making
changes". Do the procedure, and write in the PR which consumer you used.

## Repository structure

| Path                                  | What it is                                                       |
| ------------------------------------- | ---------------------------------------------------------------- |
| `<module>/<module>.just`              | The recipes of a module, with the README of the module beside it |
| `<module>.just` + `<module>.mod.just` | Older module with a shim, documented in the root README          |
| `justfile`                            | The recipes of this repository, which use the `just` module      |
| `Dockerfile`, `.dockerignore`         | Publishes all recipe files, flattened, as a scratch image        |

There are two styles to import a module. The specification defines the two
styles. Do not change one style to the other because it looks like an error.

## Commit trailer

When you commit with Claude Code, end the message with:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Task tracking

**Design is done in the design documents.** Write or change the page in
[osapi-io/specs](https://github.com/osapi-io/specs) before you build. Correct
the page where the build shows that it is wrong. A design document in this
repository becomes old when the code changes, and nothing finds the difference.
