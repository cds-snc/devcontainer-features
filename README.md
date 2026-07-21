# CDS Devcontainer Features

A collection of [Dev Container Features](https://containers.dev/implementors/features/) for use at CDS.

## Features

| Feature | Description |
|---------|-------------|
| [uv](src/uv/README.md) | A single tool to replace pip, pip-tools, pipx, poetry, pyenv, virtualenv, and more. |
| [zizmor](src/zizmor/README.md) | Static security analysis for GitHub Actions workflows. |
| [rtk](src/rtk/README.md) | CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. |
| [op](src/op/README.md) | 1Password CLI. |
| [ripgrep](src/ripgrep/README.md) | Recursively searches directories for a regex pattern while respecting your gitignore. |

## Usage

Add a feature to your `devcontainer.json`:

```json
"features": {
    "ghcr.io/cds-snc/devcontainer-features/uv:1": {},
    "ghcr.io/cds-snc/devcontainer-features/zizmor:1": {},
    "ghcr.io/cds-snc/devcontainer-features/rtk:1": {},
    "ghcr.io/cds-snc/devcontainer-features/op:1": {},
    "ghcr.io/cds-snc/devcontainer-features/ripgrep:1": {}
}
```

Note that default community health files are maintained at https://github.com/cds-snc/.github

## Testing

Tests are located in the `test/` directory and follow the [devcontainer features test](https://github.com/devcontainers/cli/blob/main/docs/features/test.md) convention.

Each feature has a `test/<feature>/test.sh` that validates the default installation, and `test/_global/` contains scenario tests for specific version pinning.

To run tests locally with the [devcontainer CLI](https://github.com/devcontainers/cli):

```bash
# Test a single feature
devcontainer features test -f uv -i mcr.microsoft.com/devcontainers/base:ubuntu .

# Test global scenarios (specific versions)
devcontainer features test --global-scenarios-only .
```
