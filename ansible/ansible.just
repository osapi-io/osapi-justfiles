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
# Consumed with `import?`, not `mod?`: recipes are flat and prefixed
# (ansible-*). Ansible runs through uv from the project's Ansible directory, so
# the version is the one its uv.lock pins, never one from the path.

ansible_dir := "ansible"
ansible_playbooks := "playbooks"

# --- Setup ---

# Install Ansible and ansible-lint from the project's uv.lock
[group('ansible')]
ansible-deps:
    cd {{ ansible_dir }} && uv sync

# --- Dev ---

# Run a playbook by name, such as `just ansible-run site -K`
[group('ansible')]
ansible-run playbook *args:
    cd {{ ansible_dir }} && uv run ansible-playbook {{ ansible_playbooks }}/{{ playbook }}.yml {{ args }}

# --- Lint ---

# Report likely mistakes in roles and playbooks, syntax included
[group('ansible')]
ansible-lint:
    cd {{ ansible_dir }} && uv run ansible-lint

# --- Test ---

# Test all (fmt check, lint)
[group('ansible')]
ansible-test: ansible-fmt-check ansible-lint

# --- Fmt ---

# Reformat roles and playbooks with ansible-lint's fixes
[group('ansible')]
ansible-fmt:
    cd {{ ansible_dir }} && uv run ansible-lint --fix

# Check roles and playbooks formatting
[group('ansible')]
ansible-fmt-check:
    cd {{ ansible_dir }} && uv run ansible-lint --tags yaml
