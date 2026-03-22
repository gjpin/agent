FROM docker.io/library/node:24

ARG PI_VERSION=0.61.1

WORKDIR /workspace

USER root

# Install sudo and grant node user passwordless sudo
RUN apt-get update && apt-get install -y sudo \
    && echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

USER node

ENV HOME=/home/node
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

##########
# pi
##########

# Install pi agent
RUN npm install -g @mariozechner/pi-coding-agent@${PI_VERSION} \
  && npm cache clean --force

##########
# ENTRYPOINT
##########

ENTRYPOINT ["pi"]
