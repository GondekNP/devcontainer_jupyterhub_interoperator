FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1000 jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /workspaces && \
    chown jovyan:jovyan /workspaces && \
    mkdir -p /home/jovyan/work && \
    chown jovyan:jovyan /home/jovyan/work

USER jovyan
WORKDIR /home/jovyan

ENV PATH="/home/jovyan/.local/bin:${PATH}"

RUN pip3 install --user jupyterlab

COPY setup_environment.sh /usr/local/bin/setup_environment.sh
USER root
RUN chmod +x /usr/local/bin/setup_environment.sh
USER jovyan

CMD ["/bin/bash", "-c", "source /usr/local/bin/setup_environment.sh && setup_workspace && exec /bin/bash"]