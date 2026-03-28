# Dependencies
```bash
# Install krunkit
brew tap slp/krun
brew install krunkit

# Install lima
brew install lima
```

# Start VM
```bash
limactl start agent.yaml --name=agent --yes
limactl shell agent
```

# Use Podman in host
```bash
# Install system helper service (provides better Docker compatibility)
sudo "$(brew --prefix)/opt/podman/bin/podman-mac-helper" install

# Export podman sockets
tee ${HOME}/.zshrc.d/podman << 'EOF'
export CONTAINER_HOST=$(limactl list agent --format 'unix://{{.Dir}}/sock/podman.sock')
export DOCKER_HOST=$(limactl list agent --format 'unix://{{.Dir}}/sock/podman.sock')

alias docker=podman
EOF
```