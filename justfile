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
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/md/md.just -o .just/remote/md.just

# Check formatting
test:
    just --justfile just/just.just --working-directory . just-fmt-check
    just md-fmt-check

# Format and lint before committing
ready:
    just --justfile just/just.just --working-directory . just-fmt
    just md-fmt
