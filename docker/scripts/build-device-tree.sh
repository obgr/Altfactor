
#!/usr/bin/env sh
set -eu

repo=""
ref=""
srcdir="/inputs/device-tree"
outdir="/out"
cross_compile="aarch64-linux-gnu-"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--repo) repo="$2"; shift 2 ;;
		--ref) ref="$2"; shift 2 ;;
		--srcdir) srcdir="$2"; shift 2 ;;
		--outdir) outdir="$2"; shift 2 ;;
		--cross-compile) cross_compile="$2"; shift 2 ;;
		*)
			echo "Unknown arg: $1" >&2
			exit 2
			;;
	esac
done

if [ -z "$repo" ]; then
	echo "Usage: build-device-tree --repo <url> [--ref <tag|branch|commit>] [--srcdir <dir>] [--outdir <dir>]" >&2
	exit 2
fi

if [ ! -d "$srcdir" ]; then
	echo "ERROR: srcdir not found: $srcdir" >&2
	exit 1
fi

mkdir -p "$outdir"

if [ -n "$ref" ]; then
	git clone --depth 1 --branch "$ref" "$repo" u-boot
else
	git clone --depth 1 "$repo" u-boot
fi

cd u-boot

# Overlay our local device-tree sources into the U-Boot tree.
(cd "$srcdir" && tar cf - .) | tar xf -

# If our Recore DT is present, ensure it's listed in arch/arm/dts/Makefile.
if [ -f arch/arm/dts/sun50i-a64-recore.dts ] && [ -f arch/arm/dts/Makefile ]; then
	if ! grep -q "sun50i-a64-recore\\.dtb" arch/arm/dts/Makefile; then
		tmp="$(mktemp)"
		awk '
			BEGIN { inserted = 0 }
			{
				print $0
				if (!inserted && $0 ~ /dtb-\\$\\(CONFIG_MACH_SUN50I\\) \\+= \\\\/) {
					print "\tsun50i-a64-recore.dtb \\\\";
					inserted = 1
				}
			}
		' arch/arm/dts/Makefile > "$tmp"
		mv "$tmp" arch/arm/dts/Makefile
	fi
fi

# Configure and build DTBs. Prefer our recore_defconfig if present.
if [ -f configs/recore_defconfig ]; then
	make CROSS_COMPILE="$cross_compile" recore_defconfig
else
	make CROSS_COMPILE="$cross_compile" sunxi_defconfig
fi

make CROSS_COMPILE="$cross_compile" dtbs

# Copy DTBs corresponding to DTS files found in the overlay.
overlay_dts_count="$(find "$srcdir" -type f -name '*.dts' | wc -l | tr -d ' ')"
if [ "$overlay_dts_count" -eq 0 ]; then
	echo "ERROR: No .dts files found under: $srcdir" >&2
	exit 1
fi

find "$srcdir" -type f -name '*.dts' | while IFS= read -r dts_path; do
	rel="${dts_path#"$srcdir"/}"
	case "$rel" in
		arch/arm/dts/*.dts)
			name="$(basename "$rel" .dts)"
			dtb="arch/arm/dts/${name}.dtb"
			if [ ! -f "$dtb" ]; then
				echo "ERROR: Expected DTB not found: $dtb" >&2
				exit 1
			fi
			cp -v "$dtb" "$outdir/${name}.dtb"
			;;
		*)
			echo "Skipping DTS outside arch/arm/dts: $rel" >&2
			;;
	esac
done

