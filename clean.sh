#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${ROOT_DIR}/out"

BUILDER_NAME="altfactor"
DOCKER_BIN="${DOCKER_BIN:-docker}"

maybe_sudo_docker() {
  if "${DOCKER_BIN}" info >/dev/null 2>&1; then
    return 0
  fi

  if command -v sudo >/dev/null 2>&1 && sudo -n "${DOCKER_BIN}" info >/dev/null 2>&1; then
    DOCKER_BIN="sudo ${DOCKER_BIN}"
    return 0
  fi

  return 1
}

echo "Cleaning local build outputs..."
if [ -d "${OUT_DIR}" ]; then
  rm -rf "${OUT_DIR}"
  echo "- Removed: ${OUT_DIR}"
else
  echo "- Not found: ${OUT_DIR}"
fi

echo
echo "Cleaning Docker buildx cache/environment (builder: ${BUILDER_NAME})..."
if maybe_sudo_docker; then
  if ${DOCKER_BIN} buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
    ${DOCKER_BIN} buildx prune --builder "${BUILDER_NAME}" -af >/dev/null 2>&1 || true
    ${DOCKER_BIN} buildx rm -f "${BUILDER_NAME}" >/dev/null 2>&1 || true
    echo "- Pruned cache and removed builder: ${BUILDER_NAME}"
  else
    echo "- Builder not found: ${BUILDER_NAME}"
  fi

  echo
  echo "Cleaning local Docker images (reference: alpfactor*)..."
  image_ids="$(${DOCKER_BIN} image ls --filter=reference='alpfactor*' -q 2>/dev/null | awk '!seen[$0]++' || true)"
  if [ -n "${image_ids}" ]; then
    # shellcheck disable=SC2086
    ${DOCKER_BIN} image rm -f ${image_ids} >/dev/null 2>&1 || true
    echo "- Removed image IDs: ${image_ids}"
  else
    echo "- No matching images found"
  fi
else
  echo "- Skipping Docker cleanup (cannot talk to Docker daemon)"
fi

echo
echo "Done."
