# How to
```bash
# Build image
podman build --build-arg PI_CODING_AGENT_VERSION=0.70.2 -t agent .

# Create .pi directory
mkdir -p "${HOME}/.pi/agent"

# Copy skills
cp -R skills "${HOME}/.pi/agent"
```

# Alias
```bash
tee ${HOME}/.zshrc.d/pi << EOF
# Web search skill
export BRAVE_API_KEY=
export LINKUP_API_KEY=
export EXA_API_KEY=

# Providers
export MISTRAL_API_KEY=
export OPENROUTER_API_KEY=
export OPENCODE_API_KEY=

# Pi alias
alias pi='podman run --rm -it \\
  --name pi \\
  --user agent \\
  -v "\${HOME}/.pi:/home/agent/.pi" \\
  -v "\$(pwd):/workspace" \\
  -w /workspace \\
  -e BRAVE_API_KEY="$BRAVE_API_KEY" \\
  -e LINKUP_API_KEY="$LINKUP_API_KEY" \\
  -e EXA_API_KEY="$EXA_API_KEY" \\
  -e OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \\
  -e OPENCODE_API_KEY="$OPENCODE_API_KEY" \\
  -e MISTRAL_API_KEY="$MISTRAL_API_KEY" \\
  agent'
EOF
```