# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.202.5/containers/python-3/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use jammy or bionic on local arm64/Apple Silicon): jammy, focal, bionic
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends python3 python3-all-dev \
        build-essential libncurses-dev libssl-dev libffi-dev pip silversearcher-ag

# Set Python 3 as default python
RUN apt-get install -y python-is-python3

# fix umask and permissions with workspace ACL
RUN apt-get install acl

# Vim and sqlite3
RUN apt-get -y install --no-install-recommends libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev \
        libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb vim sqlite3

# Install docker
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates curl gnupg2 gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt update && apt -y install docker-ce docker-ce-cli containerd.io \
    && usermod -aG docker vscode \
    && newgrp docker

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

# Install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Node 16.x
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings  
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR=16
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y nodejs
