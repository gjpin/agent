# How to
```bash
# Build image
podman build --build-arg PI_CODING_AGENT_VERSION=0.74.0 -t agent .

# Create .pi directory
mkdir -p "${HOME}/.pi/agent"

# Copy pi config
cp -R agent/* "${HOME}/.pi/agent"
```

# Exec Pi
```bash
tee ${HOME}/.zshrc.d/pi << 'EOF'
# Web search skill
export BRAVE_API_KEY=
export LINKUP_API_KEY=
export EXA_API_KEY=

# Providers
export DEEPSEEK_API_KEY=
export OPENROUTER_API_KEY=
export OPENCODE_API_KEY=

# Pi alias
pi() {
  local rel
  local workdir

  rel=$(realpath --relative-to="${HOME}/src" "$PWD")
  workdir="/workspace/$rel"

  if podman container exists pi; then
    podman start pi >/dev/null

    podman exec \
      -it \
      -w "$workdir" \
      pi pi
  else
    podman run -it \
      --name pi \
      --user agent \
      --userns keep-id \
      --security-opt no-new-privileges \
      --pids-limit 512 \
      --tmpfs /tmp:rw,nosuid,size=512m \
      --cap-drop ALL \
      --security-opt label=type:container_t \
      -v "${HOME}/.pi:/home/agent/.pi:Z" \
      -v "${HOME}/.agents:/home/agent/.agents:Z" \
      -v "${HOME}/src:/workspace:Z" \
      -w "$workdir" \
      -e BRAVE_API_KEY="${BRAVE_API_KEY}" \
      -e LINKUP_API_KEY="${LINKUP_API_KEY}" \
      -e EXA_API_KEY="${EXA_API_KEY}" \
      -e DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY}" \
      -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}" \
      -e OPENCODE_API_KEY="${OPENCODE_API_KEY}" \
      agent
  fi
}
EOF
```