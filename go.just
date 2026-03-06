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

git_root := `git rev-parse --show-toplevel`
main_package := env("JUST_MAIN_PACKAGE", "main.go")
coverage_dir := env("JUST_COVERAGE_DIR", ".coverage")
docs_dir := env("JUST_DOCS_DIR", "docs/gen")
os_tags := if os() == "linux" { `if grep -iq 'ubuntu' /etc/os-release 2>/dev/null; then echo '-tags=ubuntu'; fi` } else { "" }

# --- Private dependency recipes ---

[private]
_fmt-deps:
    go get -tool mvdan.cc/gofumpt
    go get -tool github.com/segmentio/golines

[private]
_vet-deps:
    go get -tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint

[private]
_cov-deps:
    go get -tool github.com/boumenot/gocover-cobertura

[private]
_docs-deps:
    go get -tool github.com/princjef/gomarkdoc/cmd/gomarkdoc

# --- Setup ---

# Install all tool dependencies
[group: 'setup']
deps: _fmt-deps _vet-deps _cov-deps _docs-deps

# Module maintenance (download + tidy)
[group: 'setup']
mod:
    #!/usr/bin/env bash
    go mod download
    go mod tidy
    if [ -d examples/ ] && [ "$(ls examples/)" ]; then
        for dir in examples/*/; do
            (cd "${dir}" && go mod tidy)
        done
    fi

# --- Lint ---

# Report likely mistakes in packages
[group: 'lint']
vet: _vet-deps
    go tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint run --config {{ git_root }}/.golangci.yml

# --- Dev ---

# Compile and run Go program
[group: 'dev']
run *args:
    go run {{ main_package }} {{ args }}

# --- Test ---

# Test packages
[group: 'test']
unit:
    go test {{ os_tags }} -parallel 5 -race -v ./...

# Run integration tests (requires running service)
unit-int:
    go test -tags integration -v -count=1 ./test/integration/...

# Generate coverage
[group: 'test']
unit-cov: _cov-deps
    mkdir -p {{ coverage_dir }}
    go test {{ os_tags }} -race -coverprofile={{ coverage_dir }}/cover.out -v $(go list ./...)
    grep -v -f .coverignore {{ coverage_dir }}/cover.out > {{ coverage_dir }}/cover.tmp && mv {{ coverage_dir }}/cover.tmp {{ coverage_dir }}/cover.out
    go tool github.com/boumenot/gocover-cobertura < {{ coverage_dir }}/cover.out > {{ coverage_dir }}/cobertura.xml
    go tool cover -func={{ coverage_dir }}/cover.out

# Generate coverage and show heatmap
[group: 'test']
unit-cov-map: unit-cov
    go tool cover -html={{ coverage_dir }}/cover.out

# Test all (mod, fmt check, vet, coverage)
[group: 'test']
test: mod fmt-check vet unit-cov

# --- Fmt ---

# Reformat Go files with gofumpt + golines
[group: 'fmt']
fmt: _fmt-deps
    find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' | xargs go tool mvdan.cc/gofumpt -l -w
    find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' | xargs go tool github.com/segmentio/golines --base-formatter="go tool mvdan.cc/gofumpt" -w

# Check Go file formatting
[group: 'fmt']
fmt-check: _fmt-deps
    test -z "$(find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' | xargs go tool mvdan.cc/gofumpt -d -e | tee /dev/stderr)"
    test -z "$(find . -type f -name '*.go' ! -name '*.gen.go' ! -name '*.pb.go' ! -path './.worktrees/*' ! -path './.claude/*' | xargs go tool github.com/segmentio/golines --dry-run --base-formatter="go tool mvdan.cc/gofumpt" -l | tee /dev/stderr)"

# --- Codegen ---

# Generate Go files by processing source
[group: 'codegen']
generate:
    go generate ./...

# --- Docs ---

# Generate Go package documentation
[group: 'docs']
docs: _docs-deps
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ docs_dir }}
    tmpl='{{ "{{" }}.Name{{ "}}" }}'
    for pkg in $(go list ./...); do
        name=$(go list -f "$tmpl" "$pkg")
        [[ "$name" == "mocks" || "$name" == "main" ]] && continue
        go tool github.com/princjef/gomarkdoc/cmd/gomarkdoc \
            -o "{{ docs_dir }}/${name}.md" "$pkg"
    done

# Check if generated docs are up to date
[group: 'docs']
docs-check: _docs-deps
    #!/usr/bin/env bash
    set -euo pipefail
    tmpl='{{ "{{" }}.Name{{ "}}" }}'
    for pkg in $(go list ./...); do
        name=$(go list -f "$tmpl" "$pkg")
        [[ "$name" == "mocks" || "$name" == "main" ]] && continue
        go tool github.com/princjef/gomarkdoc/cmd/gomarkdoc \
            -c -o "{{ docs_dir }}/${name}.md" "$pkg"
    done
