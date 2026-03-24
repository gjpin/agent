# Pi Coding Agent
## Install Pi agent and dependencies
```bash
# Install Pi
brew install pi-coding-agent

# Install Node and ignore pre/post install scripts
brew install node
npm config set ignore-scripts true
```

## Install skills
```bash
# Copy skills
cp -R skills ~/.pi/agent

# Install skills dependencies
for dir in ~/.pi/agent/skills/*/; do \
    if [ -f "$dir/package.json" ]; then \
    echo "Installing dependencies in $dir" && \
    cd "$dir" && npm install; \
    fi; \
done && npm cache clean --force
```

## Configure credentials, local models, agents
```bash
export BRAVE_API_KEY=
export GROQ_API_KEY=
export MISTRAL_API_KEY=
export OPENROUTER_API_KEY=
export OPENCODE_API_KEY=

# Set env vars with API keys
envsubst < ./configs/env | tee ${HOME}/.zshrc.d/pi > /dev/null

# Configure local models
cp configs/models.json ${HOME}/.pi/agent/models.json

# Configure AGENTS.md
cp configs/AGENTS.md ${HOME}/.pi/agent/AGENTS.md
```

## Sandboxing
```bash
# Install Athropic's Sandbox Runtime
# https://github.com/anthropic-experimental/sandbox-runtime
npm install -g @anthropic-ai/sandbox-runtime

cp configs/sandbox.json ~/.pi/agent/sandbox.json

mkdir -p ~/.pi/agent/extensions
cp -R extensions/sandbox ~/.pi/agent/extensions

# Install extensions dependencies
for dir in ~/.pi/agent/extensions/*/; do \
    if [ -f "$dir/package.json" ]; then \
    echo "Installing dependencies in $dir" && \
    cd "$dir" && npm install; \
    fi; \
done && npm cache clean --force
```
