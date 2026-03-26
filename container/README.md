# How to
```bash
# Build image
podman build --build-arg PI_CODING_AGENT_VERSION=0.62.0 -t agent .

# Run Pi Agent
podman run --rm --security-opt label=disable --user agent --device /dev/fuse -it agent
```

# References
- [Podman in Podman](https://www.redhat.com/en/blog/podman-inside-container)
- [Podman image](https://github.com/containers/image_build/tree/main/podman)