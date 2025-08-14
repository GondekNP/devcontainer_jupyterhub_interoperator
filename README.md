# Jupyter Dev Container Compatibility Feature

A dev container feature that makes any Jupyter container work seamlessly in VSCode dev containers and Codespaces.

## Problem

Jupyter containers are designed to work in JupyterHub environments with:
- `jovyan` user and `/home/jovyan/work` workspace
- Specific file permissions and directory structure

VSCode dev containers expect:
- `/workspaces/{project-name}` mount points  
- Different user permissions and access patterns

## Solution

This dev container feature acts as a compatibility layer that:

1. **Creates workspace symlinks** - Links `/workspaces/{project}` to `/home/jovyan/work/{project}` 
2. **Handles permissions** - Ensures both environments can access files properly
3. **Environment detection** - Only activates in VSCode dev container/Codespaces environments

## Usage

Add to your `devcontainer.json`:

```json
{
    "image": "jupyter/scipy-notebook:latest",
    "features": {
        "./src/jupyter-compat": {}
    }
}
```

### Options

```json
{
    "features": {
        "./src/jupyter-compat": {
            "jupyterUser": "jovyan",
            "jupyterWorkspace": "/home/jovyan/work"
        }
    }
}
```