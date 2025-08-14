#!/bin/bash

set -e

# Get feature options
JUPYTER_USER=${JUPYTERUSER:-"jovyan"}
JUPYTER_WORKSPACE=${JUPYTERWORKSPACE:-"/home/jovyan/work"}

echo "Setting up Jupyter dev container compatibility..."
echo "Jupyter user: $JUPYTER_USER"
echo "Jupyter workspace: $JUPYTER_WORKSPACE"

# Ensure jupyter workspace exists
if [ ! -d "$JUPYTER_WORKSPACE" ]; then
    echo "Creating Jupyter workspace: $JUPYTER_WORKSPACE"
    mkdir -p "$JUPYTER_WORKSPACE"
    if id "$JUPYTER_USER" &>/dev/null; then
        chown "$JUPYTER_USER:$JUPYTER_USER" "$JUPYTER_WORKSPACE"
    fi
fi

# Create workspaces directory if it doesn't exist
if [ ! -d "/workspaces" ]; then
    echo "Creating /workspaces directory"
    mkdir -p /workspaces
fi

# Install a service to fix workspace ownership at runtime
cat > /usr/local/bin/fix-workspace-ownership.sh << 'EOF'
#!/bin/bash

# This runs at container startup to ensure proper workspace ownership
if [ -n "${REMOTE_CONTAINERS}" ] || [ -n "${CODESPACES}" ]; then
    # In dev containers, fix ownership to match the effective user
    CURRENT_USER=$(whoami)
    if [ "$CURRENT_USER" = "root" ] && [ -d "/workspaces" ]; then
        echo "Dev container detected - ensuring workspace ownership for root user..."
        chown -R root:root /workspaces 2>/dev/null || true
    elif [ "$CURRENT_USER" != "root" ] && [ -d "/workspaces" ]; then
        echo "Dev container detected - ensuring workspace ownership for $CURRENT_USER..."
        sudo chown -R "$CURRENT_USER:$CURRENT_USER" /workspaces 2>/dev/null || true
    fi
fi
EOF

chmod +x /usr/local/bin/fix-workspace-ownership.sh

# Create a setup script that will run at container startup
cat > /usr/local/bin/setup-jupyter-devcontainer.sh << 'EOF'
#!/bin/bash

JUPYTER_USER="${1:-jovyan}"
JUPYTER_WORKSPACE="${2:-/home/jovyan/work}"

# Function to create symlinks for workspace compatibility
setup_workspace_symlinks() {
    local workspace_name
    
    # Find the actual workspace directory
    for ws in /workspaces/*; do
        if [ -d "$ws" ]; then
            workspace_name=$(basename "$ws")
            echo "Found workspace: $workspace_name"
            
            # Create symlink from jupyter workspace to vscode workspace
            if [ ! -L "$JUPYTER_WORKSPACE/$workspace_name" ]; then
                echo "Creating symlink: $JUPYTER_WORKSPACE/$workspace_name -> $ws"
                ln -sf "$ws" "$JUPYTER_WORKSPACE/$workspace_name"
            fi
            
            # If running as root, also create reverse symlink for jupyter user access
            if [ "$(id -u)" = "0" ] && id "$JUPYTER_USER" &>/dev/null; then
                jupyter_home="/home/$JUPYTER_USER"
                if [ ! -L "$ws/jupyter-home" ]; then
                    echo "Creating reverse symlink: $ws/jupyter-home -> $jupyter_home"
                    ln -sf "$jupyter_home" "$ws/jupyter-home"
                fi
            fi
        fi
    done
}

# Only run if we're in a dev container environment
if [ -n "${REMOTE_CONTAINERS}" ] || [ -n "${CODESPACES}" ]; then
    echo "Dev container environment detected, setting up workspace symlinks..."
    setup_workspace_symlinks
fi
EOF

chmod +x /usr/local/bin/setup-jupyter-devcontainer.sh

# Add setup to bashrc for interactive shells
echo "Adding setup script to shell initialization..."
cat >> /etc/bash.bashrc << EOF

# Jupyter dev container compatibility setup
if [ -n "\${REMOTE_CONTAINERS}" ] || [ -n "\${CODESPACES}" ]; then
    /usr/local/bin/fix-workspace-ownership.sh
    /usr/local/bin/setup-jupyter-devcontainer.sh "$JUPYTER_USER" "$JUPYTER_WORKSPACE"
fi
EOF

echo "Jupyter dev container compatibility feature installed successfully!"