# Dependencies
```bash
# Install krunkit
brew tap slp/krun
brew install krunkit

# Install lima
brew install lima
```

# Create and (auto)start VM
```bash
# Create VM
limactl create agent.yaml --name=agent --yes

# Autostart VM
limactl start-at-login agent

# Start VM
limactl start agent

# Access VM
limactl shell agent

# OpenCode alias
tee ${HOME}/.zshrc.d/opencode << 'EOF'
alias opencode="limactl shell agent opencode"
EOF
```

# Use Podman in host
```bash
# Install Podman
brew install podman

# Install system helper service (provides better Docker compatibility)
sudo "$(brew --prefix)/opt/podman/bin/podman-mac-helper" install

# Export podman sockets
tee ${HOME}/.zshrc.d/podman << 'EOF'
export CONTAINER_HOST=$(limactl list agent --format 'unix://{{.Dir}}/sock/podman.sock')
export DOCKER_HOST=$(limactl list agent --format 'unix://{{.Dir}}/sock/podman.sock')

alias docker=podman
EOF
```