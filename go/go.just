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
# The checks of `go-test`, in two lists. `go-ci-checks` gives CI the same
# lists: the quick checks share one job, and each slow check is a job. A
# consumer adds its own checks by assigning the lists again, as it does
# `go_coverage_target`. The unit tests are not in the lists: `go-test` runs
# them in one `go-unit-cov-check`, and CI runs them in shards.

go_quick_checks := "go-mod-check"
go_slow_checks := "go-fmt-check go-vet go-dead-check"

# `go-unit-plan` makes one shard for each `go_shard_weight` lines of test code,
# up to `go_shard_max` shards.

go_shard_weight := "20000"
go_shard_max := "10"
go_os_tags := if os() == "linux" { `if grep -iq 'ubuntu' /etc/os-release 2>/dev/null; then echo '-tags=ubuntu'; fi` } else { "" }

# --- Private dependency recipes ---

# Every tool these recipes run is already recorded in the consuming module's
# `tool (...)` block, so `go tool <pkg>` resolves it from the module graph and
# needs nothing installed. `go get -tool` would instead re-resolve each one to
# whatever is newest and rewrite go.mod and go.sum to match.
#
# That rewrite is what made `go-mod-check` unpassable. It runs in the same
# `go-test` chain, so CI mutated the checkout and then failed the build for
# being mutated: any upstream tool release turned every open pull request red,
# while the default branch stayed green only because its run predated the
# release. Downloading is enough, and it changes nothing.

[private]
_go-fmt-deps: _go-mod-download

[private]
_go-vet-deps: _go-mod-download

[private]
_go-cov-deps: _go-mod-download

[private]
_go-dead-deps: _go-mod-download

# --- Setup ---

# Install all tool dependencies
[group('go')]
go-deps: _go-fmt-deps _go-vet-deps _go-cov-deps _go-dead-deps

# Download modules without changing anything
[group('go')]
_go-mod-download:
    go mod download

# Module maintenance (download + tidy)
[group('go')]
go-mod: _go-mod-download
    #!/usr/bin/env bash
    go mod tidy
    if [ -d examples/ ]; then
        find examples/ -name go.mod -exec dirname {} \; | while read dir; do
            (cd "${dir}" && go mod tidy)
        done
    fi

# Fail when a committed module is untidy
[group('go')]
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
[group('go')]
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
[group('go')]
go-vet: _go-vet-deps
    go tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint run --config {{ go_git_root }}/.golangci.yml

# Fail on each function that no main and no test reaches. No linter finds
# them: unused skips an exported function, as API for other packages.
# deadcode skips generated files, and exits 0 when it finds some.
[group('go')]
go-dead-check: _go-dead-deps
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(go tool golang.org/x/tools/cmd/deadcode -test ./... | grep -v -e /mocks/ -e /node_modules/ || true)
    if [ -n "$out" ]; then
        echo "$out"
        echo "Remove each function above, or call it."
        exit 1
    fi

# --- Dev ---

# Compile and run Go program
[group('go')]
go-run *args:
    go run {{ go_main_package }} {{ args }}

# --- Test ---
# go_packages lists all Go packages excluding node_modules (which may
# contain vendored .go files from npm packages like flatted).

go_packages := "$(go list ./... | grep -v /node_modules/)"

# Test packages
[group('go')]
go-unit:
    go test {{ go_os_tags }} -parallel 5 -race -v {{ go_packages }}

# Run integration tests (requires running service)
[group('go')]
go-unit-int:
    go test -tags integration -v -count=1 ./test/integration/...

# Generate coverage
[group('go')]
go-unit-cov: _go-cov-deps
    mkdir -p {{ go_coverage_dir }}
    go test {{ go_os_tags }} -race -coverprofile={{ go_coverage_dir }}/cover.out -v {{ go_packages }}
    grep -v -f .coverignore {{ go_coverage_dir }}/cover.out > {{ go_coverage_dir }}/cover.tmp && mv {{ go_coverage_dir }}/cover.tmp {{ go_coverage_dir }}/cover.out
    go tool github.com/boumenot/gocover-cobertura < {{ go_coverage_dir }}/cover.out > {{ go_coverage_dir }}/cobertura.xml
    go tool cover -func={{ go_coverage_dir }}/cover.out

# Fail when total coverage is below go_coverage_target
[group('go')]
go-unit-cov-check: go-unit-cov
    #!/usr/bin/env bash
    set -euo pipefail
    total=$(go tool cover -func={{ go_coverage_dir }}/cover.out | awk '$1=="total:"{print $NF}' | tr -d '%')
    awk -v t="$total" -v g="{{ go_coverage_target }}" 'BEGIN{exit !(t+0 < g+0)}' \
      && { echo "coverage ${total}% is below target {{ go_coverage_target }}%"; exit 1; } \
      || echo "coverage ${total}% meets target {{ go_coverage_target }}%"

# Show files without 100% coverage and open heatmap of only those files
[group('go')]
go-unit-cov-gaps: go-unit-cov
    #!/usr/bin/env bash
    set -euo pipefail
    gap_files=$(go tool cover -func={{ go_coverage_dir }}/cover.out | grep -v '100.0%' | grep -v '^total:' | awk -F: '{print $1}' | sort -u || true)
    if [ -z "$gap_files" ]; then echo "No coverage gaps found."; exit 0; fi
    { head -1 {{ go_coverage_dir }}/cover.out; grep -F -f <(echo "$gap_files") {{ go_coverage_dir }}/cover.out; } > {{ go_coverage_dir }}/gaps.out
    go tool cover -html={{ go_coverage_dir }}/gaps.out

# Generate coverage and show heatmap
[group('go')]
go-unit-cov-map: go-unit-cov
    go tool cover -html={{ go_coverage_dir }}/cover.out

# Test all (mod check, fmt check, vet, coverage)
[group('go')]
go-test: _go-mod-download
    #!/usr/bin/env bash
    set -euo pipefail
    for check in {{ go_quick_checks }} {{ go_slow_checks }}; do just "$check"; done
    just go-unit-cov-check

# --- CI ---

# Print the checks of go-test as the JSON matrix of the CI check jobs
#
# Each entry is one job: the quick checks together, then each slow check.
[group('go')]
go-ci-checks:
    #!/usr/bin/env bash
    set -euo pipefail
    {
        echo "{{ go_quick_checks }}"
        for check in {{ go_slow_checks }}; do echo "$check"; done
    } | awk 'BEGIN { printf "{\"check\":[" } { printf "%s\"%s\"", (NR > 1 ? "," : ""), $0 } END { print "]}" }'

# Plan the shards of the unit tests, as the JSON matrix of the CI unit jobs
#
# Each package weighs its lines of test code, and one more, so a package with
# no tests still runs for its coverage. Each package goes to the lightest
# shard so far, the heaviest package first. A new package needs no change.
# One package is the smallest part of a shard.
[group('go')]
go-unit-plan:
    #!/usr/bin/env bash
    set -euo pipefail
    go list -e -f '{{{{.Dir}} {{{{.ImportPath}}' ./... | grep -v /node_modules/ |
        while read -r dir pkg; do
            lines=$(cat "$dir"/*_test.go 2>/dev/null | wc -l || true)
            echo "$((lines + 1)) $pkg"
        done |
        sort -rn |
        awk -v w={{ go_shard_weight }} -v max={{ go_shard_max }} '
            { weight[NR] = $1; pkg[NR] = $2; total += $1 }
            END {
                n = int((total + w - 1) / w); if (n < 1) n = 1; if (n > max) n = max
                for (i = 1; i <= NR; i++) {
                    best = 0
                    for (s = 1; s < n; s++) if (load[s] < load[best]) best = s
                    load[best] += weight[i]; list[best] = list[best] " " pkg[i]
                }
                printf "{\"include\":["
                for (s = 0; s < n; s++) {
                    sub(/^ /, "", list[s])
                    printf "%s{\"shard\":%d,\"packages\":\"%s\"}", (s ? "," : ""), s, list[s]
                }
                print "]}"
            }'

# Run the unit tests of one shard, and fail below go_coverage_target
#
# The profile is filtered through .coverignore, as go-cover-merge filters the
# joined one. With a target of 100, the shard's check gives the answer of the
# joined profile: the total is 100% only when each package is. With a lower
# target it does not, and go-cover-merge is the gate. A shard whose packages
# are each in .coverignore has nothing to count, and passes.
[group('go')]
go-unit-shard shard packages: _go-cov-deps
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ go_coverage_dir }}
    out={{ go_coverage_dir }}/shard-{{ shard }}.out
    go test {{ go_os_tags }} -race -coverprofile="$out" {{ packages }}
    grep -v -f .coverignore "$out" > "$out.tmp" && mv "$out.tmp" "$out"
    if [ "$(wc -l < "$out")" -le 1 ]; then
        echo "shard {{ shard }}: nothing to count"
        exit 0
    fi
    total=$(go tool cover -func="$out" | awk '$1=="total:"{print $NF}' | tr -d '%')
    awk -v t="$total" -v g="{{ go_coverage_target }}" 'BEGIN{exit !(t+0 < g+0)}' \
      && { go tool cover -func="$out" | grep -v '100.0%$' >&2; echo "shard {{ shard }}: coverage ${total}% is below target {{ go_coverage_target }}%" >&2; exit 1; } \
      || echo "shard {{ shard }}: coverage ${total}% meets target {{ go_coverage_target }}%"

# Join the coverage of the shards, and fail below go_coverage_target
#
# It writes the profile that go-unit-cov writes for one run: filtered through
# .coverignore, at {{ go_coverage_dir }}/cover.out. Each shard already filtered
# its profile; a second filter changes nothing.
[group('go')]
go-cover-merge:
    #!/usr/bin/env bash
    set -euo pipefail
    {
        echo "mode: atomic"
        for f in {{ go_coverage_dir }}/shard-*.out; do tail -n +2 "$f"; done
    } | grep -v -f .coverignore > {{ go_coverage_dir }}/cover.out
    total=$(go tool cover -func={{ go_coverage_dir }}/cover.out | awk '$1=="total:"{print $NF}' | tr -d '%')
    awk -v t="$total" -v g="{{ go_coverage_target }}" 'BEGIN{exit !(t+0 < g+0)}' \
      && { go tool cover -func={{ go_coverage_dir }}/cover.out | grep -v '100.0%$' >&2; echo "coverage ${total}% is below target {{ go_coverage_target }}%" >&2; exit 1; } \
      || echo "coverage ${total}% meets target {{ go_coverage_target }}%"

# --- Fmt ---

# golangci-lint formats, with the formatters that the .golangci.yml of the
# repository enables, such as gofumpt, golines and goimports. Thus the format
# that go-fmt writes, go-fmt-check checks, and go-vet reports is one format,
# from one version of each tool. golangci-lint skips generated files and
# hidden directories, such as .worktrees.

# Reformat Go files with the formatters of .golangci.yml
[group('go')]
go-fmt: _go-fmt-deps
    go tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint fmt --config {{ go_git_root }}/.golangci.yml

# Check Go file formatting
[group('go')]
go-fmt-check: _go-fmt-deps
    go tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint fmt --diff --config {{ go_git_root }}/.golangci.yml

# --- Codegen ---

# Generate Go files by processing source
[group('go')]
go-generate:
    go generate ./...

# The name go-run had before every recipe took its group as its prefix.
# Hidden from --list; remove once no repository calls it.
[private]
alias run := go-run
