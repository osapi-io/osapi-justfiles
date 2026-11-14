# just.just

Formats and checks the justfiles in a repository with the formatter of just.

## Usage

A consumer imports `just.just` with `import?`. Its recipes are flat, and their
names have a prefix. Thus it needs no `.mod.just` shim.

```just
import? '.just/remote/just.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/just/just.just -o .just/remote/just.just
```

Then:

```bash
just fetch            # Download the shared recipe file
just just-fmt         # Reformat every justfile in the repository
just just-fmt-check   # Check formatting, non-zero exit on drift
```

## What it covers

All `justfile` and `*.just` files in the repository, except these:

| Skipped        | Why                                                         |
| -------------- | ----------------------------------------------------------- |
| `**/.just/*`   | downloaded modules at any depth, which this repository owns |
| `.worktrees/*` | checkouts of other branches                                 |
| `.claude/*`    | tools generate these files and generate them again          |

## License

The [MIT](../LICENSE) License.
