#!/usr/bin/env sh
set -eu

repo=""
plat=""
debug="0"
patch=""
outdir="/out"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --plat) plat="$2"; shift 2 ;;
    --debug) debug="$2"; shift 2 ;;
    --patch) patch="$2"; shift 2 ;;
    --outdir) outdir="$2"; shift 2 ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$repo" ] || [ -z "$plat" ]; then
  echo "Usage: build-atf --repo <url> --plat <plat> [--debug 0|1] [--patch <patch>] [--outdir <dir>]" >&2
  exit 2
fi

mkdir -p "$outdir"

git clone --depth 1 "$repo" arm-trusted-firmware
cd arm-trusted-firmware

if [ -n "$patch" ]; then
  if [ ! -f "$patch" ]; then
    echo "ERROR: patch file not found at: $patch" >&2
    exit 1
  fi
  git apply "$patch"
fi

make \
  CROSS_COMPILE=aarch64-linux-gnu- \
  PLAT="$plat" \
  DEBUG="$debug" \
  SUNXI_PSCI_USE_SCPI=0 \
  SUNXI_BL31_IN_DRAM=1 \
  SEPARATE_NOBITS_REGION=0 \
  bl31

bl31_path="build/${plat}/debug/bl31.bin"
if [ ! -f "$bl31_path" ]; then
  bl31_path="build/${plat}/release/bl31.bin"
fi

if [ ! -f "$bl31_path" ]; then
  echo "ERROR: bl31.bin not found for PLAT=${plat}" >&2
  find build -maxdepth 4 -type f -name bl31.bin -print >&2 || true
  exit 1
fi

cp -v "$bl31_path" "$outdir/bl31.bin"
