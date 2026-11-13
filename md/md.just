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
# Repository markdown formatting recipes for osapi-io projects.
#
# Consumed with `import?`, not `mod?` — recipes are flat and prefixed (md-*),
# and run from the importing justfile's directory, so no working-directory shim
# is needed.
#
# Formats every .md file in the repository via mdformat, run with uvx. The gfm
# plugin is required — without it mdformat is CommonMark-only and will mangle
# GitHub-flavored tables.

md_version := "1.0.0"
md_gfm_version := "1.0.0"
md_wrap := "80"

# mdformat's --exclude requires Python 3.13+. Without pinning, uvx resolves
# whatever interpreter is on the host and the flag silently disappears —
# mdformat then exits 2 with "unrecognized arguments". uv downloads 3.13 if
# it is not already present.

md_python := "3.13"

# Excluded: .claude/ holds generated agent files that their generator rewrites.

# The Docusaurus site directory, excluded because that content holds MDX and
# component syntax mdformat cannot parse. The docusaurus module owns and formats
# it. Set to "" in a repository that publishes no site.
md_site_dir := "docs"
md_excludes := "--exclude '**/.claude/**' --exclude '**/node_modules/**' --exclude '**/.worktrees/**' --exclude '**/.just/**'"
md_site_exclude := if md_site_dir == "" { "" } else { "--exclude '" + md_site_dir + "/**'" }
md_extra_excludes := ""

# --number keeps the numbering an author wrote. Without it mdformat rewrites
# every ordered list to all-`1.`, which renders identically but produces a large
# diff and loses the numbering in the source.

# Reformat repository markdown with mdformat
[group('md')]
md-fmt:
    uvx --python {{ md_python }} --from mdformat=={{ md_version }} --with mdformat-gfm=={{ md_gfm_version }} mdformat --number --wrap {{ md_wrap }} {{ md_excludes }} {{ md_site_exclude }} {{ md_extra_excludes }} .

# Check repository markdown formatting
[group('md')]
md-fmt-check:
    uvx --python {{ md_python }} --from mdformat=={{ md_version }} --with mdformat-gfm=={{ md_gfm_version }} mdformat --check --number --wrap {{ md_wrap }} {{ md_excludes }} {{ md_site_exclude }} {{ md_extra_excludes }} .
