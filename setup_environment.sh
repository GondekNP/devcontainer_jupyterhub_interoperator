#!/bin/bash

detect_environment() {
    if [ -n "${CODESPACES}" ]; then
        echo "codespaces"
    elif [ -n "${REMOTE_CONTAINERS}" ]; then
        echo "devcontainer"  
    elif [ -n "${JUPYTERHUB_SERVICE_PREFIX}" ]; then
        echo "jupyterhub"
    elif [ -d "/home/jovyan" ]; then
        echo "jupyter"
    else
        echo "docker"
    fi
}

setup_permissions() {
    local env_type=$1
    
    case $env_type in
        "devcontainer"|"codespaces")
            if [ -d "/workspaces" ]; then
                sudo chown -R jovyan:jovyan /workspaces 2>/dev/null || true
            fi
            ;;
        "jupyterhub"|"jupyter")
            if [ -d "/home/jovyan/work" ]; then
                sudo chown -R jovyan:jovyan /home/jovyan/work 2>/dev/null || true
            fi
            ;;
        *)
            if [ -d "/workspace" ]; then
                sudo chown -R jovyan:jovyan /workspace 2>/dev/null || true
            fi
            ;;
    esac
}

setup_workspace() {
    local env_type
    env_type=$(detect_environment)
    
    echo "Detected environment: $env_type"
    
    setup_permissions "$env_type"
    
    case $env_type in
        "devcontainer"|"codespaces")
            export WORKSPACE_ROOT="/workspaces"
            export JUPYTER_ROOT_DIR="/workspaces"
            mkdir -p /workspaces
            cd /workspaces || return
            ;;
        "jupyterhub"|"jupyter")
            export WORKSPACE_ROOT="/home/jovyan/work"
            export JUPYTER_ROOT_DIR="/home/jovyan"
            mkdir -p /home/jovyan/work
            cd /home/jovyan || return
            ;;
        *)
            export WORKSPACE_ROOT="/workspace"
            export JUPYTER_ROOT_DIR="/workspace"
            mkdir -p /workspace
            cd /workspace || return
            ;;
    esac
    
    echo "Workspace root: $WORKSPACE_ROOT"
    echo "Jupyter root dir: $JUPYTER_ROOT_DIR"
}