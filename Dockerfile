FROM registry.access.redhat.com/ubi10/ubi:10.1

ARG PI_CODING_AGENT_VERSION
RUN test -n "$PI_CODING_AGENT_VERSION" || (echo "ERROR: PI_CODING_AGENT_VERSION build arg is required" && exit 1)

WORKDIR /workspace

# System packages
RUN dnf upgrade -y --refresh && \
  dnf install -y \
    bind-utils \
    jq \
    bc \
    unzip \
    wget \
    nodejs24 \
    npm \
    golang \
    python3 \
    python3-pip \
    make \
    cmake

# User setup
RUN useradd -m -s /bin/bash -G wheel agent && \
    echo 'agent:agent' | chpasswd && \
    echo 'agent ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /etc/skel.agent && \
    echo -e "root:1:65535\nagent:1:999\nagent:1001:64535" > /etc/subuid && \
    echo -e "root:1:65535\nagent:1:999\nagent:1001:64535" > /etc/subgid

# User environment
USER agent
ENV HOME=/home/agent

ENV NPM_CONFIG_PREFIX=/home/agent/.npm-global \
  GOPATH=/home/agent/.go \
  PATH=$PATH:/home/agent/.npm-global/bin:/home/agent/.go/bin

# Install npm packages
RUN npm install -g pnpm && \
  npm install -g @mariozechner/pi-coding-agent@${PI_CODING_AGENT_VERSION} && \
  npm cache clean --force

ENTRYPOINT ["pi"]
