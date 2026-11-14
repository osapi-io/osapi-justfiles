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

# Ansible recipes for osapi-io projects.
#
# Consumed with `import?`; recipes are flat and prefixed (ansible-*). Ansible
# runs through uv from the consuming project's Ansible directory, so the version
# is the one its uv.lock pins, never whatever is on the path. That directory
# holds pyproject.toml (with ansible and, as a dev dependency, ansible-lint),
# ansible.cfg, and the playbooks.
#
# Override in the consuming justfile, after the import, when the defaults do not
# fit:
#
#     ansible_dir := "ansible"
#     ansible_playbooks := "playbooks"

ansible_dir := "ansible"
ansible_playbooks := "playbooks"

# --- Setup ---

# Install Ansible and its tools from the project's uv.lock
[group('setup')]
ansible-deps:
    cd {{ ansible_dir }} && uv sync

# --- Run ---

# Run a playbook by name, such as `just ansible-play site -K`
[group('run')]
ansible-play playbook *args:
    cd {{ ansible_dir }} && uv run ansible-playbook {{ ansible_playbooks }}/{{ playbook }}.yml {{ args }}

# --- Lint ---

# Report likely mistakes in roles and playbooks
[group('lint')]
ansible-lint:
    cd {{ ansible_dir }} && uv run ansible-lint

# Check every playbook parses
[group('lint')]
ansible-syntax:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{ ansible_dir }}
    for playbook in {{ ansible_playbooks }}/*.yml; do
      uv run ansible-playbook --syntax-check "$playbook" > /dev/null
    done

# --- Test ---

# Test all (fmt check, lint, syntax)
[group('test')]
ansible-test: ansible-fmt-check ansible-lint ansible-syntax

# --- Fmt ---

# Reformat roles and playbooks with ansible-lint's fixes
[group('fmt')]
ansible-fmt:
    cd {{ ansible_dir }} && uv run ansible-lint --fix

# Check roles and playbooks formatting
[group('fmt')]
ansible-fmt-check:
    cd {{ ansible_dir }} && uv run ansible-lint --tags yaml
