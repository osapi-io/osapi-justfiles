# docusaurus.just

This module builds, serves, deploys, and formats a
[Docusaurus](https://docusaurus.io) site.

## Usage

A consumer imports `docusaurus.just` with `import?`, not with `mod?`. Its
recipes are flat, and their names have a prefix. Thus it needs no `.mod.just`
shim.

```just
import? '.just/remote/docusaurus.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/docusaurus/docusaurus.just -o .just/remote/docusaurus.just
```

Then run these recipes:

```bash
just fetch                    # Download the shared recipe file
just docs-deps                # Install the site's dependencies
just docs-start               # Development server
just docs-build               # Build the site
just docs-serve               # Serve the built site
just docs-deploy              # Deploy
just docs-clean               # Remove build output
just docs-fmt                 # Reformat the site with Prettier
just docs-fmt-check           # Check site formatting
just docs-generate            # Regenerate the OpenAPI reference pages
just docs-bump 1.2.0          # Cut a versioned snapshot
```

## Configuration

| Variable          | Default     | Purpose                       |
| ----------------- | ----------- | ----------------------------- |
| `docusaurus_dir`  | `docs`      | Directory that holds the site |
| `docusaurus_host` | `localhost` | Development server host       |
| `docusaurus_port` | `3001`      | Development server port       |

To change a variable, set `allow-duplicate-variables`. Then assign the variable
again:

```just
set allow-duplicate-variables

import? '.just/remote/docusaurus.just'

docusaurus_port := "3002"
```

## Format

This module formats its own directory, and the [`md`](../md/README.md) module
does not format it. Docusaurus content has MDX and component syntax that
mdformat cannot parse. Thus only Prettier formats those files.

In a repository that uses the two modules, set `md_site_dir` to the value of
`docusaurus_dir`. Then the exclusion agrees with the location of the site.

## License

The [MIT](../LICENSE) License.
