FROM docker.io/library/node:24

ARG PI_VERSION=0.61.1

WORKDIR /workspace

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
