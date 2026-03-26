# Start VM
limactl start fedora.yaml --name=fedora-agent --cpus=2 --memory=4 --containerd=none --yes
limactl shell fedora-agent