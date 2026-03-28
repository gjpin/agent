# Start VM
limactl start fedora.yaml --name=fedora-agent --yes
limactl shell fedora-agent

# Use Podman in host
```bash
# Set Docker host path
tee ${HOME}/.zshrc.d/podman << 'EOF'
export CONTAINER_HOST=$(limactl list fedora-agent --format 'unix://{{.Dir}}/sock/podman.sock')
export DOCKER_HOST=$(limactl list fedora-agent --format 'unix://{{.Dir}}/sock/podman.sock')

alias docker=podman
EOF
```