<p align="center">
  <picture>
    <source srcset="asset/logo-dark.svg" media="(prefers-color-scheme: dark)">
    <source srcset="asset/logo-light.svg" media="(prefers-color-scheme: light)">
    <img src="asset/logo-dark.svg" alt="osapi-justfiles" width="707">
  </picture>
</p>

<p align="center">The shared just recipes that every osapi-io repository uses to build.</p>

<p align="center">
  <a href="https://github.com/osapi-io/osapi-justfiles/actions/workflows/just-lint.yml"><img alt="just lint" src="https://img.shields.io/github/actions/workflow/status/osapi-io/osapi-justfiles/just-lint.yml?branch=main&style=for-the-badge"></a>
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-brightgreen.svg?style=for-the-badge"></a>
  <a href="https://conventionalcommits.org"><img alt="conventional commits" src="https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge"></a>
  <a href="https://just.systems"><img alt="built with just" src="https://img.shields.io/badge/Built_with-Just-black?style=for-the-badge&logo=just&logoColor=white"></a>
  <img alt="gitHub commit activity" src="https://img.shields.io/github/commit-activity/m/osapi-io/osapi-justfiles?style=for-the-badge">
</p>

<p align="center">
<b>The build is in one place, so six repositories agree.</b>
</p>

<p align="center">
This repository has six modules of just recipes. Each repository in the
organization downloads them over HTTP and imports them as optional. Thus all
repositories run the same build steps. No repository keeps a copy.
</p>

## Usage

A consumer imports the shared recipes with `import?`. Each module is one recipe
file. The consumer downloads it from this repository into `.just/remote/`.

The name of each variable starts with the module name. The name of each recipe
starts with its group. `just --list` shows the group as a heading. The group is
the module name. The exception is `docusaurus`, which has the recipes `docs-*`.

```just
import? '.just/remote/go.just'
import? '.just/remote/md.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/go/go.just -o .just/remote/go.just
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/md/md.just -o .just/remote/md.just
```

Then run `just fetch` to download the shared recipes. After that, you can run
each recipe by its prefixed name:

```bash
$ just fetch          # Download shared justfiles
$ just go-deps        # Install all Go tool dependencies
$ just go-test        # Run all Go checks
$ just go-mod-bump    # Update dependencies under examples/
$ just go-fmt         # Auto-format code
$ just md-fmt-check   # Check markdown formatting
```

A module has a default for each value that can be different in each repository.
To use a different value, set `allow-duplicate-variables`. Then assign the
variable again:

```just
set allow-duplicate-variables

import? '.just/remote/go.just'

go_coverage_target := "99.9"
```

Add `.just/` to `.gitignore`:

```
.just/
```

### Lazy tool dependencies

Each recipe installs its own tools the first time that it runs. It uses private
`_*-deps` recipes to do this. Thus you do not have to run `deps` before you use
a recipe. `go-deps` installs all the tools at one time, before you need them.

A consumer defines a top-level `deps` recipe that calls the `deps` recipe of
each module:

```just
# Install all dependencies
deps:
    just go-deps
    go get -tool github.com/golang/mock/mockgen
```

### Documentation generation

`go-docs` and `go-docs-check` use
[gomarkdoc](https://github.com/princjef/gomarkdoc) to generate one markdown file
for each package into `JUST_DOCS_DIR`. They do not generate files for the
`mocks` and `main` packages. By default, `go-test` does **not** include
`go-docs-check`. If you need it, add it to the `test` recipe of your consumer:

```just
test:
    just go-test
    just go-docs-check
```

### Nested Go modules

A Go module under `examples/` has its own `go.mod`. Dependabot does not watch
it. `go-mod-bump` updates these Go modules. `go-mod-check` fails when a
committed Go module is not tidy. `go-test` depends on `go-mod-check`.
[go/README.md](go/README.md) has the details.

## Documentation

Each module is in its own directory, with a README that describes it:

| Module       | Description                                              | Docs                                         |
| ------------ | -------------------------------------------------------- | -------------------------------------------- |
| `ansible`    | Ansible run, lint and format, through uv                 | [ansible/README.md](ansible/README.md)       |
| `docusaurus` | Docusaurus site build, serve, deploy, format             | [docusaurus/README.md](docusaurus/README.md) |
| `go`         | Go build, test, coverage gate, format, lint              | [go/README.md](go/README.md)                 |
| `md`         | Repository markdown format (mdformat via uvx)            | [md/README.md](md/README.md)                 |
| `just`       | Justfile format                                          | [just/README.md](just/README.md)             |
| `react`      | React application build, lint, format, SDK codegen (Bun) | [react/README.md](react/README.md)           |

## Contributing

The [Contributing](CONTRIBUTING.md) guide gives the prerequisites, the recipe
conventions, and the pull request workflow.

## License

The [MIT](LICENSE) License.
