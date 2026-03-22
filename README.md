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
  -v "\${HOME}/.pi:/home/node/.pi" \\
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

## Setup providers
```bash
# https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/providers.md
# https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/models.md

mkdir -p ${HOME}/.pi/agent

tee ${HOME}/.pi/agent/auth.json << 'EOF'
{
  "mistral": { "type": "api_key", "key": "" },
  "openrouter": { "type": "api_key", "key": "" },
  "opencode": { "type": "api_key", "key": "" }
}
EOF

chmod 0600 ${HOME}/.pi/agent/auth.json
```

# Skills

## Available Skills

| Skill | Description |
|-------|-------------|
| [brave-search](brave-search/SKILL.md) | Web search and content extraction via Brave Search |
| [browser-tools](browser-tools/SKILL.md) | Interactive browser automation via Chrome DevTools Protocol |
| [transcribe](transcribe/SKILL.md) | Speech-to-text transcription via Groq Whisper API |
| [vscode](vscode/SKILL.md) | VS Code integration for diffs and file comparison |
| [zed](zed/SKILL.md) | Zed integration for diffs and file comparison |
| [youtube-transcript](youtube-transcript/SKILL.md) | Fetch YouTube video transcripts |

## Requirements

Some skills require additional setup. Generally, the agent will walk you through that. But if not, here you go:

- **brave-search**: Requires Node.js. Run `npm install` in the skill directory.
- **browser-tools**: Requires Chrome and Node.js. Run `npm install` in the skill directory.
- **transcribe**: Requires curl and a Groq API key.
- **vscode**: Requires VS Code with `code` CLI in PATH.
- **zed**: Requires Zed with `zed` CLI in PATH.
- **youtube-transcript**: Requires Node.js. Run `npm install` in the skill directory.

## References:
- [badlogic's pi skills](https://github.com/badlogic/pi-skills)

## Skills setup
- Brave Search: get API key from https://api-dashboard.search.brave.com/app/keys.
- Transcribe: get API key from https://console.groq.com/keys
- Browser Tools: see chrome/

```bash
# Node
brew install node
npm config set ignore-scripts true

# Skills
for dir in ~/.pi/agent/skills/*/; do \
    if [ -f "$dir/package.json" ]; then \
    echo "Installing dependencies in $dir" && \
    cd "$dir" && npm install; \
    fi; \
done && npm cache clean --force
```
