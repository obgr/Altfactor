#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${ROOT_DIR}/out"

BUILDER_NAME="altfactor"
TARGET_ARCH="${TARGET_ARCH:-arm64}"
DEBIAN_IMAGE="${DEBIAN_IMAGE:-debian:trixie-slim}"

mkdir -p "${OUT_DIR}"

DOCKER_BIN="${DOCKER_BIN:-docker}"
if ! "${DOCKER_BIN}" info >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1 && sudo -n "${DOCKER_BIN}" info >/dev/null 2>&1; then
    DOCKER_BIN="sudo ${DOCKER_BIN}"
  else
    echo "ERROR: Cannot talk to Docker daemon (permission denied on /var/run/docker.sock)." >&2
    echo "Fix by either:" >&2
    echo "- Run: sudo ./build.sh" >&2
    echo "- Or add your user to the docker group and re-login" >&2
    exit 1
  fi
fi

if ! ${DOCKER_BIN} buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
  ${DOCKER_BIN} buildx create --name "${BUILDER_NAME}" --use
else
  ${DOCKER_BIN} buildx use "${BUILDER_NAME}"
fi

${DOCKER_BIN} buildx build \
  --file "${ROOT_DIR}/docker/Dockerfile" \
  --target export \
  --build-arg "TARGET_ARCH=${TARGET_ARCH}" \
  --build-arg "DEBIAN_IMAGE=${DEBIAN_IMAGE}" \
  --output "type=local,dest=${OUT_DIR}" \
  --progress=plain \
  "${ROOT_DIR}"

echo
echo "Build complete. Artifacts:"
echo "- ${OUT_DIR}/atf/bl31.bin"
echo "- ${OUT_DIR}/u-boot/u-boot-sunxi-with-spl.bin"
echo "- ${OUT_DIR}/device-tree/sun50i-a64-recore.dtb"
