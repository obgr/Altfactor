#!/usr/bin/env sh
set -eu

repo=""
defconfig=""
patch=""
ref=""
bl31=""
outdir="/out"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --ref) ref="$2"; shift 2 ;;
    --defconfig) defconfig="$2"; shift 2 ;;
    --patch) patch="$2"; shift 2 ;;
    --bl31) bl31="$2"; shift 2 ;;
    --outdir) outdir="$2"; shift 2 ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$repo" ] || [ -z "$defconfig" ] || [ -z "$bl31" ]; then
  echo "Usage: build-uboot --repo <url> [--ref <tag|branch|commit>] --defconfig <defconfig> --bl31 <path> [--patch <patch>] [--outdir <dir>]" >&2
  exit 2
fi

if [ ! -f "$bl31" ]; then
  echo "ERROR: BL31 not found at: $bl31" >&2
  exit 1
fi

mkdir -p "$outdir"

if [ -n "$ref" ]; then
  # --branch works with tags as well.
  git clone --depth 1 --branch "$ref" "$repo" u-boot
else
  git clone --depth 1 "$repo" u-boot
fi
cd u-boot

if [ -n "$patch" ]; then
  if [ ! -f "$patch" ]; then
    echo "ERROR: patch file not found at: $patch" >&2
    exit 1
  fi
  git apply "$patch"
fi

make \
  CROSS_COMPILE=aarch64-linux-gnu- \
  BL31="$bl31" \
  SCP=/dev/null \
  "$defconfig"

make \
  CROSS_COMPILE=aarch64-linux-gnu- \
  BL31="$bl31" \
  SCP=/dev/null

artifact="u-boot-sunxi-with-spl.bin"
if [ ! -f "$artifact" ]; then
  echo "ERROR: Expected artifact not found: $artifact" >&2
  ls -lah >&2
  exit 1
fi

cp -v "$artifact" "$outdir/$artifact"
