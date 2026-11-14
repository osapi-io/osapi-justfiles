# ansible.just

Runs, lints and formats Ansible, through [uv](https://docs.astral.sh/uv/), from
a project's Ansible directory.

## Usage

Consumed with `import?`, like `md.just`. Its recipes are flat and prefixed, and
run from the importing justfile's directory:

```just
import? '.just/remote/ansible.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/ansible/ansible.just -o .just/remote/ansible.just
```

A project's own recipes name its playbooks and call `ansible-play`:

```just
# Show what the lab is running
list:
    just ansible-play list
```

## Recipes

| Recipe                        | Description                                           |
| ----------------------------- | ----------------------------------------------------- |
| `ansible-deps`                | Install Ansible and its tools from the `uv.lock`      |
| `ansible-play playbook *args` | Run `playbooks/<playbook>.yml`, passing `args` along  |
| `ansible-lint`                | Report likely mistakes in roles and playbooks         |
| `ansible-syntax`              | Check every playbook parses                           |
| `ansible-test`                | `ansible-fmt-check`, `ansible-lint`, `ansible-syntax` |
| `ansible-fmt`                 | Reformat with `ansible-lint --fix`                    |
| `ansible-fmt-check`           | Fail on YAML formatting drift                         |

## Variables

| Variable            | Default     | Meaning                                         |
| ------------------- | ----------- | ----------------------------------------------- |
| `ansible_dir`       | `ansible`   | The Ansible directory, from the repository root |
| `ansible_playbooks` | `playbooks` | Where playbooks are, inside `ansible_dir`       |

Override one by defining it after the import, with
`set allow-duplicate-variables`.

## Requirements

[uv](https://docs.astral.sh/uv/), and an Ansible directory holding:

- `pyproject.toml` depending on `ansible`, with `ansible-lint` as a dev
  dependency, and the `uv.lock` that pins them.
- `ansible.cfg`. Ansible reads it from the current directory, which is why every
  recipe runs from `ansible_dir`.

Every recipe goes through `uv run`, so the Ansible that runs is the one the lock
file pins. An `ansible-playbook` on the path is never used: it is whatever
somebody happened to install, and it differs from machine to machine and from
continuous integration.

`ansible-fmt-check` runs only ansible-lint's `yaml` rules, so it reports
formatting and nothing else. `ansible-fmt` applies every fix ansible-lint knows,
which includes module names as well as formatting; `ansible-lint` reports
whatever is left.

## License

The [MIT](../LICENSE) License.
