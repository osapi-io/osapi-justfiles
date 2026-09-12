# go.just

Builds, tests, formats, lints, and measures coverage for a Go project using
[gofumpt](https://github.com/mvdan/gofumpt),
[golines](https://github.com/segmentio/golines),
[golangci-lint](https://golangci-lint.run), and `go test`.

## Usage

`go.just` is consumed with `import?` rather than `mod?`. Its recipes are flat
and prefixed, so it needs no `.mod.just` shim:

```just
import? '.just/remote/go.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/go/go.just -o .just/remote/go.just
```

Then:

```bash
just fetch                 # Download the shared recipe file
just go-deps               # Install tool dependencies
just go-test               # mod-check, fmt-check, vet, coverage gate
just go-unit               # Unit tests only
just go-unit-cov           # Generate a coverage profile
just go-unit-cov-check     # Fail below the coverage target
just go-unit-cov-gaps      # Open a heatmap of files under 100%
just go-fmt                # Reformat with gofumpt and golines
just go-fmt-check          # Check formatting
just go-vet                # Run golangci-lint
just go-generate           # Run go generate
just go-mod                # Download, then tidy the root and examples/
just go-mod-check          # Fail when a committed module is untidy
just go-mod-bump           # Update dependencies of the modules under examples/
```

### Nested modules

A module under `examples/` has its own `go.mod`, and Dependabot watches only the
directory its config names. `go-mod-bump` updates them, with `go get -u`
followed by `go mod tidy`: tidy alone reconciles what a module already requires
and never advances a version. The root module is left to Dependabot, since
bumping it here would also move the tool versions `go get -tool` manages.

`go-mod-check` reports untidy modules rather than repairing them, and `go-test`
depends on it. `go-mod` performs the fix, and the check's failure message names
it. The check replaces the tidy in the test chain rather than following it: run
after `go-mod`, it would always find a tidy tree, which is how CI stayed green
over untidy committed modules for months. CI tidied in a throwaway checkout and
discarded the result.

Both no-op where there is no `examples/` directory.

## Configuration

| Variable             | Default     | Purpose                                  |
| -------------------- | ----------- | ---------------------------------------- |
| `go_coverage_target` | `100`       | Minimum total coverage; below this fails |
| `go_coverage_dir`    | `.coverage` | Where the profile is written             |
| `go_main_package`    | `main.go`   | Entry point for builds                   |
| `go_fmt_excludes`    | (empty)     | Paths gofumpt and golines skip           |

### Overriding a default

Set `allow-duplicate-variables` and assign the variable again:

```just
set allow-duplicate-variables := true

import? '.just/remote/go.just'

go_coverage_target := "99.9"
```

The assignment is in scope when just parses the file, so
`just go-unit-cov-check` and `just test` agree, and a one-off override works on
the command line:

```bash
just go_coverage_target=95 go-unit-cov-check
```

Do not use `export` for this. It reaches child processes but not the parse of
its own file, so a recipe run by name would use the default while the same
recipe reached through another recipe used the override.

## License

The [MIT](../LICENSE) License.
