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
# React recipes for osapi-io projects.
#
# These recipes use Bun as the package manager and script runner. Prettier
# handles formatting and ESLint handles linting, both configured by the
# consuming project.
#
# The consuming justfile MUST define `react_dir` — the directory holding the
# React application, relative to the repository root. This module does not
# define it: a flat import shares one scope, so a default here could not be
# overridden, and the path differs per repository.
#
#     react_dir := "ui"
#     import? '.just/remote/react.just'
#
# Omitting it fails at parse time with "Variable `react_dir` not defined",
# rather than silently running in the wrong directory.

react_dir := "."
react_fmt_pattern := "src/**/*.{ts,tsx,css}"

# --- Setup ---

# Install all dependencies
[group('react')]
react-deps:
    cd {{ react_dir }} && bun install

# --- Dev ---

# Start development server
[group('react')]
react-dev:
    cd {{ react_dir }} && bun run dev

# --- Build ---

# Production build
[group('react')]
react-build:
    cd {{ react_dir }} && bun run build

# --- Lint ---

# Report likely mistakes in source
[group('react')]
react-lint:
    cd {{ react_dir }} && bun run lint

# --- Test ---

# Test all (fmt check, lint, build)
[group('react')]
react-test: react-fmt-check react-lint react-build

# --- Fmt ---

# Reformat source with Prettier
[group('react')]
react-fmt:
    cd {{ react_dir }} && bunx prettier --write "{{ react_fmt_pattern }}"

# Check source formatting
[group('react')]
react-fmt-check:
    cd {{ react_dir }} && bunx prettier --check "{{ react_fmt_pattern }}"

# --- Codegen ---

# Generate TypeScript SDK from OpenAPI spec
[group('react')]
react-generate:
    cd {{ react_dir }} && bunx orval
