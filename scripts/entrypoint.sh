#!/bin/sh
set -eu

IMAGE_AGENT_ROOT="${PI_IMAGE_AGENT_ROOT:-/home/node/.pi-bundled/agent}"
MANAGED_AGENT_ROOT="${PI_MANAGED_AGENT_ROOT:-/tmp/pi-agent-managed}"
RUNTIME_AGENT_DIR="${PI_RUNTIME_AGENT_DIR:-/home/node/.pi/agent}"

IMAGE_AGENTS_FILE="${IMAGE_AGENT_ROOT}/AGENTS.md"
IMAGE_SKILLS_DIR="${IMAGE_AGENT_ROOT}/skills"

MANAGED_AGENTS_FILE="${MANAGED_AGENT_ROOT}/AGENTS.md"
MANAGED_SKILLS_DIR="${MANAGED_AGENT_ROOT}/skills"

TARGET_AGENTS_FILE="${RUNTIME_AGENT_DIR}/AGENTS.md"
TARGET_SKILLS_DIR="${RUNTIME_AGENT_DIR}/skills"

if [ ! -f "${IMAGE_AGENTS_FILE}" ]; then
  echo "Missing bundled AGENTS.md at ${IMAGE_AGENTS_FILE}" >&2
  exit 1
fi

if [ ! -d "${IMAGE_SKILLS_DIR}" ]; then
  echo "Missing bundled skills directory at ${IMAGE_SKILLS_DIR}" >&2
  exit 1
fi

mkdir -p "${MANAGED_AGENT_ROOT}" "${RUNTIME_AGENT_DIR}"

rm -rf "${MANAGED_AGENTS_FILE}"
cp "${IMAGE_AGENTS_FILE}" "${MANAGED_AGENTS_FILE}"

rm -rf "${MANAGED_SKILLS_DIR}"
cp -R "${IMAGE_SKILLS_DIR}" "${MANAGED_SKILLS_DIR}"

rm -rf "${TARGET_AGENTS_FILE}"
ln -s "${MANAGED_AGENTS_FILE}" "${TARGET_AGENTS_FILE}"

rm -rf "${TARGET_SKILLS_DIR}"
ln -s "${MANAGED_SKILLS_DIR}" "${TARGET_SKILLS_DIR}"

if [ "$#" -eq 0 ]; then
  set -- pi
fi

exec "$@"
