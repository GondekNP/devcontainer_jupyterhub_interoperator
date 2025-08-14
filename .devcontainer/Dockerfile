FROM jupyter/scipy-notebook:latest

# Switch to root to install the feature (simulating what dev container tools do)
USER root

# Copy the feature files
COPY jupyter-compat /tmp/dev-container-features/jupyter-compat

# Set environment variables for the feature (simulating dev container tools)
ENV JUPYTERUSER=jovyan
ENV JUPYTERWORKSPACE=/home/jovyan/work

# Install the feature (simulating what dev container tools do)
RUN cd /tmp/dev-container-features/jupyter-compat && \
    chmod +x install.sh && \
    ./install.sh

# Clean up
RUN rm -rf /tmp/dev-container-features

# Switch back to jovyan user
USER jovyan

# Set working directory
WORKDIR /workspaces