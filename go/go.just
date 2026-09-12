# Copyright (c) 2026 John Dewey
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
# Go recipes for osapi-io projects.
#
# These recipes use `go tool` to run tools declared in the consuming project's
# go.mod via Go 1.24+ tool directives. Tool dependencies are installed lazily
# by the recipes that need them. Run `just deps` to install all tools upfront,
# or let each recipe pull its own on first use.
#
# Projects can add extra tools by defining their own `deps` recipe
# that depends on `go::deps`.

go_git_root := `git rev-parse --show-toplevel`
go_main_package := "main.go"
go_coverage_dir := ".coverage"

# Minimum total coverage, enforced by `go-unit-cov-check`. A consuming justfile
# overrides this by setting `allow-duplicate-variables` and assigning it again.

go_coverage_target := "100"
go_fmt_excludes := ""
go_os_tags := if os() == "linux" { `if grep -iq 'ubuntu' /etc/os-release 2>/dev/null; then echo '-tags=ubuntu'; fi` } else { "" }

# --- Private dependency recipes ---

[private]
_go-fmt-deps:
    go get -tool mvdan.cc/gofumpt
    go get -tool github.com/segmentio/golines

[private]
_go-vet-deps:
    go get -tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint

[private]
_go-cov-deps:
    go get -tool github.com/boumenot/gocover-cobertura

# --- Setup ---

# Install all tool dependencies
[group('setup')]
go-deps: _go-fmt-deps _go-vet-deps _go-cov-deps

# Module maintenance (download + tidy)
[group('setup')]
go-mod:
    #!/usr/bin/env bash
    go mod download
    go mod tidy
    if [ -d examples/ ]; then
        find examples/ -name go.mod -exec dirname {} \; | while read dir; do
            (cd "${dir}" && go mod tidy)
        done
    fi

# Fail when a committed module is untidy
[group('setup')]
go-mod-check:
    #!/usr/bin/env bash
    # go-mod runs inside a throwaway CI checkout, so tidying there fixes
    # nothing and the committed drift survives every green build. This
    # reports it instead of repairing it.
    set -euo pipefail
    status=0
    if ! go mod tidy -diff; then
        echo "untidy: ." >&2
        status=1
    fi
    if [ -d examples/ ]; then
        while read -r dir; do
            if ! (cd "${dir}" && go mod tidy -diff); then
                echo "untidy: ${dir}" >&2
                status=1
            fi
        done < <(find examples/ -name go.mod -exec dirname {} \;)
    fi
    if [ "${status}" -ne 0 ]; then
        echo "run 'just go-mod' and commit the result" >&2
    fi
    exit "${status}"

# Update dependencies of the modules under examples/
[group('setup')]
go-mod-bump:
    #!/usr/bin/env bash
    # Dependabot watches the directory its config names, which is the root.
    # Modules under examples/ have their own go.mod and nothing moves them,
    # so this does. go mod tidy alone only reconciles what a module already
    # requires; go get -u is what advances a version.
    #
    # The root is left to Dependabot on purpose. Bumping it here would also
    # drag along the tool versions `go get -tool` manages.
    set -euo pipefail
    if [ ! -d examples/ ]; then
        echo "no examples/ directory, nothing to bump"
        exit 0
    fi
    find examples/ -name go.mod -exec dirname {} \; | while read -r dir; do
        echo "bumping ${dir}"
        (cd "${dir}" && go get -u ./... && go mod tidy)
    done

# --- Lint ---

# Report likely mistakes in packages
[group('lint')]
go-vet: _go-vet-deps
    go tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint run --config {{ go_git_root }}/.golangci.yml

# --- Dev ---

# Compile and run Go program
[group('dev')]
run *args:
    go run {{ go_main_package }} {{ args }}

# --- Test ---
# go_packages lists all Go packages excluding node_modules (which may
# contain vendored .go files from npm packages like flatted).

go_packages := "$(go list ./... | grep -v /node_modules/)"

# Test packages
[group('test')]
go-unit:
    go test {{ go_os_tags }} -parallel 5 -race -v {{ go_packages }}

# Run integration tests (requires running service)
go-unit-int:
    go test -tags integration -v -count=1 ./test/integration/...

# Generate coverage
[group('test')]
go-unit-cov: _go-cov-deps
    mkdir -p {{ go_coverage_dir }}
    go test {{ go_os_tags }} -race -coverprofile={{ go_coverage_dir }}/cover.out -v {{ go_packages }}
    grep -v -f .coverignore {{ go_coverage_dir }}/cover.out > {{ go_coverage_dir }}/cover.tmp && mv {{ go_coverage_dir }}/cover.tmp {{ go_coverage_dir }}/cover.out
    go tool github.com/boumenot/gocover-cobertura < {{ go_coverage_dir }}/cover.out > {{ go_coverage_dir }}/cobertura.xml
    go tool cover -func={{ go_coverage_dir }}/cover.out

# Fail when total coverage is below go_coverage_target
[group('test')]
go-unit-cov-check: go-unit-cov
    #!/usr/bin/env bash
    set -euo pipefail
    total=$(go tool cover -func={{ go_coverage_dir }}/cover.out | awk '$1=="total:"{print $NF}' | tr -d '%')
    awk -v t="$total" -v g="{{ go_coverage_target }}" 'BEGIN{exit !(t+0 < g+0)}' \
      && { echo "coverage ${total}% is below target {{ go_coverage_target }}%"; exit 1; } \
      || echo "coverage ${total}% meets target {{ go_coverage_target }}%"

# Show files without 100% coverage and open heatmap of only those files
[group('test')]
go-unit-cov-gaps: go-unit-cov
    #!/usr/bin/env bash
    set -euo pipefail
    gap_files=$(go tool cover -func={{ go_coverage_dir }}/cover.out | grep -v '100.0%' | grep -v '^total:' | awk -F: '{print $1}' | sort -u || true)
    if [ -z "$gap_files" ]; then echo "No coverage gaps found."; exit 0; fi
    { head -1 {{ go_coverage_dir }}/cover.out; grep -F -f <(echo "$gap_files") {{ go_coverage_dir }}/cover.out; } > {{ go_coverage_dir }}/gaps.out
    go tool cover -html={{ go_coverage_dir }}/gaps.out

# Generate coverage and show heatmap
[group('test')]
go-unit-cov-map: go-unit-cov
    go tool cover -html={{ go_coverage_dir }}/cover.out

# Test all (mod, fmt check, vet, coverage)
[group('test')]
go-test: go-mod go-fmt-check go-vet go-unit-cov-check

# --- Fmt ---

# Reformat Go files with gofumpt + golines
[group('fmt')]
go-fmt: _go-fmt-deps
    find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' ! -path '*/node_modules/*' {{ go_fmt_excludes }} | xargs go tool mvdan.cc/gofumpt -l -w
    find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' ! -path '*/node_modules/*' {{ go_fmt_excludes }} | xargs go tool github.com/segmentio/golines --base-formatter="go tool mvdan.cc/gofumpt" -w

# Check Go file formatting
[group('fmt')]
go-fmt-check: _go-fmt-deps
    test -z "$(find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' ! -path '*/node_modules/*' {{ go_fmt_excludes }} | xargs go tool mvdan.cc/gofumpt -d -e | tee /dev/stderr)"
    test -z "$(find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' ! -path '*/node_modules/*' {{ go_fmt_excludes }} | xargs go tool github.com/segmentio/golines --dry-run --base-formatter="go tool mvdan.cc/gofumpt" -l | tee /dev/stderr)"

# --- Codegen ---

# Generate Go files by processing source
[group('codegen')]
go-generate:
    go generate ./...
