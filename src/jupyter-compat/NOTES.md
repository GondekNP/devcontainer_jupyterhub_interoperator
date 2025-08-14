# Jupyter Dev Container Compatibility Feature

## Overview

Makes any Jupyter container work seamlessly in VSCode dev containers by handling user permissions and workspace compatibility automatically.

## Example Usage

```json
{
    "name": "My Jupyter Project",
    "image": "jupyter/scipy-notebook:latest",
    "features": {
        "ghcr.io/your-username/devcontainer-features/jupyter-compat:1": {}
    },
    "remoteUser": "root"
}
```

## How it works

- **Environment detection**: Automatically detects dev container vs JupyterHub environments
- **User management**: Uses root in dev containers, jovyan in JupyterHub  
- **Workspace symlinks**: Creates bidirectional links between `/workspaces` and `/home/jovyan/work`
- **Permission handling**: Ensures file ownership matches the running user

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| jupyterUser | string | "jovyan" | The Jupyter user account name |
| jupyterWorkspace | string | "/home/jovyan/work" | The Jupyter workspace directory |