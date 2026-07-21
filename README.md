# CDS Devcontainer Features

A collection of [Dev Container Features](https://containers.dev/implementors/features/) for use at CDS.

## Features

| Feature | Description |
|---------|-------------|
| [uv](src/uv/README.md) | A single tool to replace pip, pip-tools, pipx, poetry, pyenv, virtualenv, and more. |
| [zizmor](src/zizmor/README.md) | Static security analysis for GitHub Actions workflows. |
| [rtk](src/rtk/README.md) | CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. |
| [op](src/op/README.md) | 1Password CLI. |

## Usage

Add a feature to your `devcontainer.json`:

```json
"features": {
    "ghcr.io/cds-snc/devcontainer-features/uv:1": {},
    "ghcr.io/cds-snc/devcontainer-features/zizmor:1": {},
    "ghcr.io/cds-snc/devcontainer-features/rtk:1": {},
    "ghcr.io/cds-snc/devcontainer-features/op:1": {}
}
```

Note that default community health files are maintained at https://github.com/cds-snc/.github
