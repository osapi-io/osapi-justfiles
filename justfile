set allow-duplicate-variables

# Justfile formatting recipes run against local recipe files, and markdown
# formatting for this repository's own documentation.

import? '.just/remote/md.just'

# No documentation site, so md formats every markdown file in the repository.
md_site_dir := ""

# List the recipes
default:
    @just --list

# Fetch shared justfiles from osapi-justfiles
#
# It fetches the commit that main is at, not refs/heads/main: the raw URL of a
# branch is cached for five minutes, so a run just after a merge got the old
# modules and said nothing (osapi-io/osapi-justfiles#108). git ls-remote asks
# the server and has no cache, and the URL of a commit never changes. The
# commit goes to .just/remote/VERSION, so a build records what it used.
fetch:
    #!/usr/bin/env bash
    set -euo pipefail
    sha=$(git ls-remote https://github.com/osapi-io/osapi-justfiles refs/heads/main | cut -f1)
    base="https://raw.githubusercontent.com/osapi-io/osapi-justfiles/$sha"
    mkdir -p .just/remote
    for module in md; do
        curl -sSfL "$base/$module/$module.just" -o ".just/remote/$module.just"
    done
    echo "$sha" > .just/remote/VERSION
    echo "osapi-justfiles $sha"

# Check formatting
test:
    just --justfile just/just.just --working-directory . just-fmt-check
    just md-fmt-check

# Format and lint before committing
ready:
    just --justfile just/just.just --working-directory . just-fmt
    just md-fmt
