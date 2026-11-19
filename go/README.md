# go.just

This module builds, tests, formats and lints a Go project, and measures its
coverage. It uses [golangci-lint](https://golangci-lint.run) and `go test`.

golangci-lint also formats. `go-fmt` and `go-fmt-check` run `golangci-lint fmt`
with the formatters that the `.golangci.yml` of the repository enables, such as
gofumpt, golines and goimports. Thus `go-fmt` writes, `go-fmt-check` checks and
`go-vet` reports the same format, from one version of each tool. The repository
records only golangci-lint in its `tool (...)` block. golangci-lint skips
generated files and hidden directories, such as `.worktrees`. To skip other
paths, add them to `formatters.exclusions.paths` in `.golangci.yml`.

## Usage

A consumer imports `go.just` with `import?`, not with `mod?`. Its recipes are
flat, and their names have a prefix. Thus it needs no `.mod.just` shim:

```just
import? '.just/remote/go.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/go/go.just -o .just/remote/go.just
```

Then run these recipes:

```bash
just fetch                 # Download the shared recipe file
just go-deps               # Install tool dependencies
just go-test               # mod-check, fmt-check, vet, coverage gate
just go-unit               # Unit tests only
just go-unit-cov           # Generate a coverage profile
just go-unit-cov-check     # Fail below the coverage target
just go-unit-cov-gaps      # Open a heatmap of files under 100%
just go-fmt                # Reformat with the formatters of .golangci.yml
just go-fmt-check          # Check formatting
just go-vet                # Run golangci-lint
just go-generate           # Run go generate
just go-run *args          # Compile and run the main package
just go-mod                # Download, then tidy the root and examples/
just go-mod-check          # Fail when a committed module is untidy
just go-mod-bump           # Update dependencies of the modules under examples/
```

### Nested Go modules

A Go module under `examples/` has its own `go.mod`. Dependabot watches only the
directory that its configuration names. `go-mod-bump` updates these Go modules.
It runs `go get -u`, then `go mod tidy`. `go mod tidy` alone makes the Go module
agree only with what it already requires. It never increases a version.

Dependabot updates the root Go module. `go-mod-bump` does not update the root Go
module, because an update there also changes the tool versions that
`go get -tool` manages.

`go-mod-check` reports Go modules that are not tidy, but it does not repair
them. `go-test` depends on `go-mod-check`. `go-mod` does the repair. The failure
message of the check names `go-mod`.

In the test chain, the check replaces the tidy step. It does not run after the
tidy step. A check that runs after `go-mod` always finds a tidy tree. This
occurred before. For months, CI passed while committed Go modules were not tidy.
CI made the Go modules tidy in a temporary checkout, and then discarded the
result.

If there is no `examples/` directory, the two recipes do nothing.

## Configuration

| Variable             | Default     | Purpose                                  |
| -------------------- | ----------- | ---------------------------------------- |
| `go_coverage_target` | `100`       | Minimum total coverage; below this fails |
| `go_coverage_dir`    | `.coverage` | Where the recipes write the profile      |
| `go_main_package`    | `main.go`   | Entry point for builds                   |

### Change a default

Set `allow-duplicate-variables`. Then assign the variable again:

```just
set allow-duplicate-variables := true

import? '.just/remote/go.just'

go_coverage_target := "99.9"
```

The assignment is in scope when just parses the file. Thus
`just go-unit-cov-check` and `just test` use the same value. You can also change
the value for one run on the command line:

```bash
just go_coverage_target=95 go-unit-cov-check
```

Do not use `export` for this. An exported variable goes to child processes, but
just does not use it when it parses its own file. Thus a recipe that you run by
name uses the default. When another recipe runs the same recipe, it uses the new
value.

## License

The [MIT](../LICENSE) License.
