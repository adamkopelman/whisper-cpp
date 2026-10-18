#!/usr/bin/env sh
# Downloads the Whisper model this build uses (ggml-tiny.bin, multilingual, ~74 MB) from
# https://huggingface.co/ggerganov/whisper.cpp into models/ggml-tiny.bin next to this script,
# and verifies its SHA-256. Safe to re-run: an existing, verified model is left alone.
#
#   sh download-model.sh            (Git Bash, WSL, macOS, Linux)
set -eu

URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
SHA256="be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21"
DIR="$(cd "$(dirname "$0")" && pwd)/models"
DEST="$DIR/ggml-tiny.bin"

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

if [ -f "$DEST" ] && [ "${1:-}" != "--force" ]; then
  if [ "$(sha256 "$DEST")" = "$SHA256" ]; then echo "OK: $DEST is already present and verified."; exit 0; fi
  echo "Existing $DEST has the wrong checksum; downloading it again."
fi

mkdir -p "$DIR"
echo "Downloading $URL ..."
curl -L --fail --retry 3 -o "$DEST.part" "$URL"
actual="$(sha256 "$DEST.part")"
if [ "$actual" != "$SHA256" ]; then
  rm -f "$DEST.part"
  echo "Checksum mismatch for ggml-tiny.bin: expected $SHA256, got $actual. Nothing was installed." >&2
  exit 1
fi
mv -f "$DEST.part" "$DEST"
echo "OK: saved and verified $DEST"
