# react.just

This module builds, lints, formats, and serves a React application with
[Bun](https://bun.sh), [Prettier](https://prettier.io),
[ESLint](https://eslint.org), and [orval](https://orval.dev).

## Usage

A consumer imports `react.just` with `import?`, not with `mod?`. Its recipes are
flat, and their names have a prefix. Thus it needs no `.mod.just` shim.

```just
import? '.just/remote/react.just'

# Fetch shared justfiles from osapi-justfiles
fetch:
    mkdir -p .just/remote
    curl -sSfL https://raw.githubusercontent.com/osapi-io/osapi-justfiles/refs/heads/main/react/react.just -o .just/remote/react.just
```

The default of `react_dir` is `.`, the repository root. If the application is in
a different directory, change `react_dir`. See Configuration.

Then run these recipes:

```bash
just fetch              # Download the shared recipe file
just react-deps         # Install dependencies
just react-dev          # Start the development server
just react-build        # Production build
just react-fmt          # Reformat with Prettier
just react-fmt-check    # Check formatting
just react-lint         # Run ESLint
just react-test         # fmt-check, lint, build
just react-generate     # Regenerate the TypeScript SDK with orval
```

## Configuration

| Variable            | Default                 | Purpose                                    |
| ------------------- | ----------------------- | ------------------------------------------ |
| `react_dir`         | `.`                     | Directory that holds the React application |
| `react_fmt_pattern` | `src/**/*.{ts,tsx,css}` | Glob that Prettier formats                 |

To change a variable, set `allow-duplicate-variables`. Then assign the variable
again:

```just
set allow-duplicate-variables := true

import? '.just/remote/react.just'

react_dir := "ui"
```

## License

The [MIT](../LICENSE) License.
