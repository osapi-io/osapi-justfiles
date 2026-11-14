# ansible.just

Runs, lints and formats [Ansible](https://docs.ansible.com) through
[uv](https://docs.astral.sh/uv/). The recipes run from the Ansible directory of
the consumer.

## Usage

A consumer imports `ansible.just` with `import?`, not with `mod?`. Its recipes
are flat, and their names have a prefix. Thus it needs no `.mod.just` shim.

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

The recipes of the consumer name its playbooks:

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

To change a variable, define it again after the import, with
`set allow-duplicate-variables`.

The Ansible directory holds `ansible.cfg`. Ansible reads this file from the
current directory, thus each recipe runs from the Ansible directory. The
directory also holds a `pyproject.toml` and a `uv.lock`. The `pyproject.toml`
has a dependency on `ansible`, and a dev dependency on `ansible-lint`. The
`uv.lock` pins their versions.

Each recipe runs through `uv run`. The recipes never use an Ansible on the path,
because its version is not known.

`ansible-fmt-check` runs only the `yaml` rules of ansible-lint. Thus it fails
only on formatting. `ansible-fmt` applies all the fixes that ansible-lint knows.
`ansible-lint` reports the problems that remain. Its `syntax-check` rule parses
each playbook, thus there is no separate recipe for the syntax check.

## License

The [MIT](../LICENSE) License.
