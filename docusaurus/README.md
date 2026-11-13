# docusaurus.just

Builds, serves, deploys, and formats a [Docusaurus](https://docusaurus.io) site.

## Usage

`docusaurus.just` is consumed with `import?` rather than `mod?`. Its recipes are
flat and prefixed, so it needs no `.mod.just` shim.

```just
import? '.just/remote/docusaurus.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/docusaurus/docusaurus.just -o .just/remote/docusaurus.just
```

Then:

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

| Variable          | Default     | Purpose                    |
| ----------------- | ----------- | -------------------------- |
| `docusaurus_dir`  | `docs`      | Directory holding the site |
| `docusaurus_host` | `localhost` | Development server host    |
| `docusaurus_port` | `3001`      | Development server port    |

Override by setting `allow-duplicate-variables` and assigning again:

```just
set allow-duplicate-variables

import? '.just/remote/docusaurus.just'

docusaurus_port := "3002"
```

## Formatting

This module formats its own directory, and the [`md`](../md/README.md) module
excludes it. Docusaurus content contains MDX and component syntax that mdformat
cannot parse, so prettier owns those files.

Set `md_site_dir` to the same value in repositories that use both, so the
exclusion matches where the site actually is.

## License

The [MIT](../LICENSE) License.
