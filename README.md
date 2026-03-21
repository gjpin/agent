# Agent
## Build image
```bash
podman build --build-arg PI_VERSION=0.61.1 -t pi-agent .
```

# Alias
```bash
BRAVE_API_KEY=
GROQ_API_KEY=
OPENROUTER_API_KEY=
OPENCODE_API_KEY=
MISTRAL_API_KEY=

mkdir -p "${HOME}/.pi/agent"

tee ${HOME}/.zshrc.d/pi << EOF
# Pi alias
alias pi='podman run --rm -it \\
  --name pi \\
  --userns=keep-id \\
  --user \$(id -u):\$(id -g) \\
  -v "\${HOME}/.pi/agent:/home/node/.pi/agent" \\
  -v "\$(pwd):/workspace" \\
  -w /workspace \\
  -e BRAVE_API_KEY="$BRAVE_API_KEY" \\
  -e GROQ_API_KEY="$GROQ_API_KEY" \\
  -e OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \\
  -e OPENCODE_API_KEY="$OPENCODE_API_KEY" \\
  -e MISTRAL_API_KEY="$MISTRAL_API_KEY" \\
  pi-agent'
EOF
```

The image manages `AGENTS.md` and `skills/` itself and recreates them inside `/home/node/.pi/agent` on startup. Persist only `${HOME}/.pi/agent` as writable runtime state, and do not mount all of `${HOME}/.pi`.

## Skills setup
- Brave Search: get API key from https://api-dashboard.search.brave.com/app/keys.
- Transcribe: get API key from https://console.groq.com/keys
- Browser Tools: see chrome/
