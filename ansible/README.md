# ansible.just

Runs, lints and formats [Ansible](https://docs.ansible.com) through
[uv](https://docs.astral.sh/uv/), from a project's Ansible directory.

## Usage

`ansible.just` is consumed with `import?` rather than `mod?`. Its recipes are
flat and prefixed, so it needs no `.mod.just` shim.

```just
import? '.just/remote/ansible.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/ansible/ansible.just -o .just/remote/ansible.just
```

Then:

```bash
just fetch                   # Download the shared recipe file
just ansible-deps            # Install Ansible and ansible-lint from uv.lock
just ansible-run <playbook>  # Run playbooks/<playbook>.yml; extra args pass through
just ansible-fmt             # Reformat with ansible-lint's fixes
just ansible-fmt-check       # Check formatting
just ansible-lint            # Run ansible-lint, syntax check included
just ansible-test            # fmt-check, lint
```

A project's own recipes name its playbooks:

```just
# Rebuild the fleet
push:
    just ansible-run push -K
```

## Configuration

| Variable            | Default     | Meaning                                         |
| ------------------- | ----------- | ----------------------------------------------- |
| `ansible_dir`       | `ansible`   | The Ansible directory, from the repository root |
| `ansible_playbooks` | `playbooks` | Where playbooks are, inside `ansible_dir`       |

Override one by defining it after the import, with
`set allow-duplicate-variables`.

The Ansible directory holds `ansible.cfg`, which Ansible reads from the current
directory, so every recipe runs from there. It also holds a `pyproject.toml`
depending on `ansible`, with `ansible-lint` as a dev dependency, and the
`uv.lock` that pins them. Every recipe goes through `uv run`; an Ansible on the
path is never used, since it is whatever somebody happened to install.

`ansible-fmt-check` runs only ansible-lint's `yaml` rules, so it fails on
formatting and nothing else. `ansible-fmt` applies every fix ansible-lint knows;
`ansible-lint` reports what is left, and its `syntax-check` rule parses every
playbook, so no separate syntax recipe is needed.

## License

The [MIT](../LICENSE) License.
