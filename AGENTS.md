# AGENTS.md

Test: `just test` | Fix the format: `just ready`

Read @CONTRIBUTING.md first.

@CONTRIBUTING.md gives the prerequisites, the procedure to test a change against
a real consumer, the recipe conventions, and the pull request workflow. These
rules apply to agents the same as they apply to people. This file has only the
rules that are specific to agents.

## Run tools through mise

Run tools through `mise`, not from your path:

```bash
mise exec -- just test
```

`mise` is active in the shell of a person and supplies the versions that
`.mise.toml` declares. The shell of an agent has no activation. Thus a bare
`just` resolves to the version that is installed globally, which is usually
older.

The symptom is a check that fails here and passes in CI, on a file that nobody
changed.

If this occurs, find the version of `just` that ran. Do this before you accept
the failure as real.

## Where the rules come from

@CONTRIBUTING.md names the design page under "Before you start".

If a convention in this repository does not agree with the design page, follow
the design page. Report the difference. Do not follow the code.

## This repository cannot test a shared recipe

Nothing in this repository runs a recipe from start to end. Thus "it looks
right" is not evidence. @CONTRIBUTING.md gives the procedure under "Making
changes".

Do the procedure. In the pull request, name the consumer that you used.

## Repository structure

| Path                          | What it is                                                       |
| ----------------------------- | ---------------------------------------------------------------- |
| `<module>/<module>.just`      | The recipes of a module, with the README of the module beside it |
| `justfile`                    | The recipes of this repository, which use the `just` module      |
| `Dockerfile`, `.dockerignore` | Publishes all recipe files, flattened, as a scratch image        |

A consumer imports a module in one way: `import?` of the downloaded recipe file.
The root README shows it.

## Commit trailer

When you commit with Claude Code, end the message with:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Design before you build

Write or change the design page in
[osapi-io/specs](https://github.com/osapi-io/specs) before you build. If the
build shows that the page is wrong, correct the page.

A design page in this repository becomes incorrect when the code changes. No
check finds the difference.
