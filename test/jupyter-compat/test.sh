#!/bin/bash

set -e

# Test script for jupyter-compat feature
echo "Testing Jupyter Dev Container Compatibility feature..."

# Test 1: Check if setup script was installed
echo "Test 1: Checking if setup script exists..."
if [ -f "/usr/local/bin/setup-jupyter-devcontainer.sh" ]; then
    echo "✓ Setup script installed"
else
    echo "✗ Setup script not found"
    exit 1
fi

# Test 2: Check if script is executable
echo "Test 2: Checking if setup script is executable..."
if [ -x "/usr/local/bin/setup-jupyter-devcontainer.sh" ]; then
    echo "✓ Setup script is executable"
else
    echo "✗ Setup script is not executable"
    exit 1
fi

# Test 3: Check if bash initialization was set up
echo "Test 3: Checking bash initialization setup..."
if grep -q "setup-jupyter-devcontainer.sh" /etc/bash.bashrc; then
    echo "✓ Bash initialization configured"
else
    echo "✗ Bash initialization not configured"
    exit 1
fi

# Test 4: Check if Jupyter workspace exists
echo "Test 4: Checking if Jupyter workspace exists..."
if [ -d "/home/jovyan/work" ]; then
    echo "✓ Jupyter workspace exists"
else
    echo "✗ Jupyter workspace not found"
    exit 1
fi

# Test 5: Check if workspaces directory exists
echo "Test 5: Checking if workspaces directory exists..."
if [ -d "/workspaces" ]; then
    echo "✓ Workspaces directory exists"
else
    echo "✗ Workspaces directory not found"
    exit 1
fi

echo "All tests passed! 🎉"