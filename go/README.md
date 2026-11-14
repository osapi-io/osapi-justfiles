# go.just

Builds, tests, formats, lints, and measures coverage for a Go project with
[gofumpt](https://github.com/mvdan/gofumpt),
[golines](https://github.com/segmentio/golines),
[golangci-lint](https://golangci-lint.run), and `go test`.

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
just go-run *args          # Compile and run the main package
just go-mod                # Download, then tidy the root and examples/
just go-mod-check          # Fail when a committed module is untidy
just go-mod-bump           # Update dependencies of the modules under examples/
```

### Nested modules

A Go module under `examples/` has its own `go.mod`. Dependabot watches only the
directory that its configuration names. `go-mod-bump` updates these Go modules.
It runs `go get -u`, then `go mod tidy`. Tidy alone only makes the module agree
with what it already requires, and it never increases a version. Dependabot
updates the root module. If `go-mod-bump` updated the root module, it would also
change the tool versions that `go get -tool` manages.

`go-mod-check` reports Go modules that are not tidy, but it does not repair
them. `go-test` depends on `go-mod-check`. `go-mod` does the repair, and the
failure message of the check names `go-mod`. In the test chain, the check
replaces the tidy step. It does not run after the tidy step. If the check ran
after `go-mod`, it would always find a tidy tree. This occurred before. For
months, CI passed while committed Go modules were not tidy. CI made the modules
tidy in a temporary checkout, and then discarded the result.

If there is no `examples/` directory, the two recipes do nothing.

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

The assignment is in scope when just parses the file. Thus
`just go-unit-cov-check` and `just test` use the same value. You can also change
the value for one run on the command line:

```bash
just go_coverage_target=95 go-unit-cov-check
```

Do not use `export` for this. An exported variable goes to child processes, but
just does not use it when it parses its own file. Thus a recipe that you run by
name uses the default. The same recipe, when another recipe runs it, uses the
new value.

## License

The [MIT](../LICENSE) License.
