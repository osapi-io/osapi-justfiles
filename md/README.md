# md.just

This module formats all `.md` files in the repository with
[mdformat](https://pypi.org/project/mdformat/), which
[uvx](https://docs.astral.sh/uv/) runs.

Use this module for a repository that keeps its documentation at the root. Use
[`docusaurus.just`](../docusaurus/README.md) for a Docusaurus site under
`docs/`.

## Usage

A consumer imports `md.just` with `import?`, not with `mod?`. Its recipes are
flat, and their names have a prefix. Thus it needs no `.mod.just` shim, and it
runs from the directory of the justfile that imports it:

```just
import? '.just/remote/md.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/md/md.just -o .just/remote/md.just
```

Then run these recipes:

```bash
just fetch          # Download the shared recipe file
just md-fmt         # Reformat all markdown
just md-fmt-check   # Check formatting (non-zero exit on drift)
```

## Recipes

| Recipe         | Description                              |
| -------------- | ---------------------------------------- |
| `md-fmt`       | Format repository markdown with mdformat |
| `md-fmt-check` | Check the format of repository markdown  |

## Requirements

The module needs only [uv](https://docs.astral.sh/uv/). It installs nothing into
the consumer, and commits nothing to it:

- `uvx` runs mdformat from a cache.
- The recipe pins the versions.
- The recipe gives the format options on the command line.

Thus there is no `package.json`, lockfile, or configuration file to maintain.

The `mdformat-gfm` plugin is necessary. Without it, mdformat knows only
CommonMark. It then changes GitHub-flavored tables into prose, and gives no
error.

The recipes pin the interpreter to Python 3.13 with `uvx --python`. The
`--exclude` flag of mdformat needs Python 3.13 or newer. On an older
interpreter, the flag does not exist, and mdformat exits 2 with
`unrecognized arguments`. The pin gives the same behavior on a laptop and in CI.
If the interpreter is not there, uv downloads it.

## Exclusions

By default, the module does not format `node_modules/`, `.worktrees/`,
`.claude/`, `.just/`, and the Docusaurus site directory, `docs/`
(`md_site_dir`).

A tool generates the files in `.claude/`, and writes them again later. If the
module formats them, CI and the tool change the same files again and again.

**⚠️ Do not use `md.just` and `docusaurus.just` on the same files.** The two
modules use different formatters, mdformat and Prettier, and they give different
output. Thus each module reverses the changes of the other. A repository can use
the two modules, but on different paths. `md.just` does not format the directory
in `md_site_dir`, `docs` by default. `docusaurus.just` formats that directory.
If the site is in a different directory, set `md_site_dir` to that directory. If
the repository has no site, set `md_site_dir` to `""`:

```just
set allow-duplicate-variables := true

import? '.just/remote/md.just'

md_site_dir := "website"
```

mdformat does not know the GitHub alert syntax (`> [!WARNING]`). It changes an
alert into a plain blockquote. Thus in a repository that this module formats,
use bold text for callouts.

## Configuration

| Variable            | Default | Description                                    |
| ------------------- | ------- | ---------------------------------------------- |
| `md_version`        | `1.0.0` | mdformat version                               |
| `md_gfm_version`    | `1.0.0` | mdformat-gfm plugin version                    |
| `md_wrap`           | `80`    | Line wrap width                                |
| `md_site_dir`       | `docs`  | Site directory that the module does not format |
| `md_extra_excludes` | (empty) | Extra `--exclude` flags added to the defaults  |
| `md_python`         | `3.13`  | Python interpreter (`--exclude` needs 3.13+)   |

To change a variable, set `allow-duplicate-variables`. Then assign the variable
again:

```just
set allow-duplicate-variables := true

import? '.just/remote/md.just'

md_wrap := "100"
```

## License

The [MIT](../LICENSE) License.
