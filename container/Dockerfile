FROM quay.io/fedora/fedora:44

ARG PI_CODING_AGENT_VERSION
RUN test -n "$PI_CODING_AGENT_VERSION" || (echo "ERROR: PI_CODING_AGENT_VERSION build arg is required" && exit 1)

WORKDIR /workspace

##########
# Packages
##########

RUN dnf upgrade -y --refresh && \
  rpm --setcaps shadow-utils && \
  dnf install -y \
  # podman
  podman \
  fuse-overlayfs \
  openssh-clients \
  cpp \
  git-core \
  sqlite \
  # misc
  bind-utils \
  unrar \
  xq \
  jq \
  yq \
  fd-find \
  fzf \
  bc \
  ripgrep \
  unzip \
  wget \
  # development tools
  nodejs24 \
  pnpm \
  golang \
  python3 \
  python3-pip \
  uv \
  ruff \
  ty \
  opentofu \
  kubernetes1.35-client \
  helm \
  make \
  gcc-c++ \
  clang \
  clang-tools-extra \
  llvm

##########
# User setup
##########

RUN useradd -m -s /bin/bash -G wheel agent && \
    echo 'agent:agent' | chpasswd && \
    echo 'agent ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /etc/skel.agent && \
    echo -e "root:1:65535\nagent:1:999\nagent:1001:64535" > /etc/subuid && \
    echo -e "root:1:65535\nagent:1:999\nagent:1001:64535" > /etc/subgid

##########
# Podman configuration
##########

# Podman configuration
ADD /containers.conf /etc/containers/containers.conf
ADD /agent-containers.conf /home/agent/.config/containers/containers.conf

RUN mkdir -p /home/agent/.local/share/containers && \
    chown agent:agent -R /home/agent && \
    chmod 644 /etc/containers/containers.conf

# Required for running with fuse-overlay storage inside container.
RUN sed -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

# Setup internal Podman to pass subscriptions down from host to internal container
RUN printf '/run/secrets/etc-pki-entitlement:/run/secrets/etc-pki-entitlement\n/run/secrets/rhsm:/run/secrets/rhsm\n' > /etc/containers/mounts.conf

# Volumes for Podman storage and configuration
VOLUME /var/lib/containers
VOLUME /home/agent/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

# Enable rootless Podman and Buildah inside the container without extra privileges
ENV _CONTAINERS_USERNS_CONFIGURED="" \
    BUILDAH_ISOLATION=chroot

##########
# User environment
##########

USER agent
ENV HOME=/home/agent

ENV NPM_CONFIG_PREFIX=/home/agent/.npm-global \
  GOPATH=/home/agent/.go \
  PATH=$PATH:/home/agent/.npm-global/bin:/home/agent/.go/bin

# Install pi agent
RUN npm install -g @mariozechner/pi-coding-agent@${PI_CODING_AGENT_VERSION} \
  && npm cache clean --force

ENTRYPOINT ["pi"]
