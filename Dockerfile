FROM docker.io/library/node:24-slim

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
# AGENTS.md
##########

# Create runtime and bundled agent directories, then copy AGENTS.md
RUN mkdir -p /home/node/.pi/agent /home/node/.pi-bundled/agent \
  && chmod 777 /home/node/.pi /home/node/.pi/agent

COPY --chown=node:node AGENTS.md /home/node/.pi-bundled/agent/AGENTS.md

##########
# SKILLS
##########

# Create bundled skills directory and copy all skills
RUN mkdir -p /home/node/.pi-bundled/agent/skills

COPY --chown=node:node skills/brave-search /home/node/.pi-bundled/agent/skills/brave-search
COPY --chown=node:node skills/browser-tools /home/node/.pi-bundled/agent/skills/browser-tools
COPY --chown=node:node skills/transcribe /home/node/.pi-bundled/agent/skills/transcribe
COPY --chown=node:node skills/vscode /home/node/.pi-bundled/agent/skills/vscode
COPY --chown=node:node skills/youtube-transcript /home/node/.pi-bundled/agent/skills/youtube-transcript
COPY --chown=node:node skills/zed /home/node/.pi-bundled/agent/skills/zed

# Install skill dependencies (only where package.json exists)
RUN for dir in /home/node/.pi-bundled/agent/skills/*/; do \
      if [ -f "$dir/package.json" ]; then \
        echo "Installing dependencies in $dir" && \
        cd "$dir" && npm install; \
      fi; \
    done && npm cache clean --force

##########
# ENTRYPOINT
##########

COPY --chown=node:node scripts/entrypoint.sh /home/node/.npm-global/bin/pi-entrypoint
RUN chmod 755 /home/node/.npm-global/bin/pi-entrypoint

ENTRYPOINT ["pi-entrypoint"]
CMD ["pi"]
