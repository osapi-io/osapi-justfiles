[![just lint](https://img.shields.io/github/actions/workflow/status/osapi-io/osapi-justfiles/just-lint.yml?branch=main&style=for-the-badge)](https://github.com/osapi-io/osapi-justfiles/actions/workflows/just-lint.yml)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=for-the-badge)](LICENSE)
[![conventional commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge)](https://conventionalcommits.org)
[![built with just](https://img.shields.io/badge/Built_with-Just-black?style=for-the-badge&logo=just&logoColor=white)](https://just.systems)
![gitHub commit activity](https://img.shields.io/github/commit-activity/m/osapi-io/osapi-justfiles?style=for-the-badge)

# osapi-justfiles

A justfile used by osapi-io projects.

## Usage

Shared recipes are consumed with `import?`. Each module is a single recipe file
whose recipes and variables are prefixed with the module name, fetched from this
repo into `.just/remote/`.

```just
import? '.just/remote/go.just'
import? '.just/remote/md.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/go/go.just -o .just/remote/go.just
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/md/md.just -o .just/remote/md.just
```

Then run `just fetch` to download the shared recipes, and they become available
by their prefixed names:

```bash
$ just fetch          # Download shared justfiles
$ just go-deps        # Install all Go tool dependencies
$ just go-test        # Run all Go checks
$ just go-mod-bump    # Update dependencies under examples/
$ just go-fmt         # Auto-format code
$ just md-fmt-check   # Check markdown formatting
```

A module ships defaults for anything that varies by repository. To use a
different value, set `allow-duplicate-variables` and assign it again:

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

Each recipe installs its own tool dependencies on first use via private
`_*-deps` recipes. There is no need to run `deps` before using a recipe. Tools
are pulled automatically. `go-deps` is a convenience that installs all tools
upfront.

Projects define a top-level `deps` recipe that calls each module's `deps`:

```just
# Install all dependencies
deps:
    just go-deps
    go get -tool github.com/golang/mock/mockgen
```

### Documentation generation

`go-docs` and `go-docs-check` use
[gomarkdoc](https://github.com/princjef/gomarkdoc) to generate one markdown file
per package into `JUST_DOCS_DIR`, skipping `mocks` and `main` packages.
`go-docs-check` is **not** included in `go-test` by default. Add it to your
project's `test` recipe where needed:

```just
test:
    just go-test
    just go-docs-check
```

### Nested modules

A module under `examples/` has its own `go.mod` that Dependabot does not watch.
`go-mod-bump` updates them and `go-mod-check`, which `go-test` depends on, fails
when a committed one is untidy. [go/README.md](go/README.md) has the detail.

## Documentation

Each module lives in its own directory and documents itself:

| Module       | Description                                       | Docs                                         |
| ------------ | ------------------------------------------------- | -------------------------------------------- |
| `docusaurus` | Docusaurus site build, serve, deploy, formatting  | [docusaurus/README.md](docusaurus/README.md) |
| `go`         | Go build, test, coverage gate, format, lint       | [go/README.md](go/README.md)                 |
| `md`         | Repository markdown formatting (mdformat via uvx) | [md/README.md](md/README.md)                 |
| `just`       | Justfile formatting                               | [just/README.md](just/README.md)             |
| `react`      | React app build, lint, format, SDK codegen (Bun)  | [react/README.md](react/README.md)           |

## Contributing

See the [Contributing](CONTRIBUTING.md) guide for prerequisites, setup,
conventions, and the PR workflow.

## License

The [MIT](LICENSE) License.
