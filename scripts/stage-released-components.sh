#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${RELEASE_TAG:?RELEASE_TAG is required}"
: "${VERSION:?VERSION is required}"
: "${ARCHITECTURE:?ARCHITECTURE is required}"

root=${1:-.}
work=${RUNNER_TEMP:?RUNNER_TEMP is required}/unetic-components
rm -rf "$work"
mkdir -p "$work"

download_binary() {
  local repository=$1
  local name=$2
  local output=$3
  local asset_prefix="unetic-${repository##unetic-}-${VERSION}-openwrt-"

  gh release download "$RELEASE_TAG" \
    --repo "Unetic/$repository" \
    --pattern "${asset_prefix}*${ARCHITECTURE}" \
    --pattern SHA256SUMS \
    --dir "$work/$name"

  (cd "$work/$name" && sha256sum -c SHA256SUMS --ignore-missing)
  local downloaded
  downloaded=$(find "$work/$name" -maxdepth 1 -name "${asset_prefix}*${ARCHITECTURE}" -print -quit)
  install -m 755 "$downloaded" "$output"
}

mkdir -p "$root/feed/unetic-core/source" "$root/feed/unetic-cli/source" "$root/feed/unetic-web/source"

printf '%s\n' "$VERSION" > "$root/feed/unetic-core/source/VERSION"
printf '%s\n' "$VERSION" > "$root/feed/unetic-cli/source/VERSION"
printf '%s\n' "$VERSION" > "$root/feed/unetic-web/source/VERSION"

download_binary unetic-core core "$root/feed/unetic-core/source/openwrt-binary"
download_binary unetic-cli cli "$root/feed/unetic-cli/source/openwrt-binary"

gh release download "$RELEASE_TAG" \
  --repo Unetic/unetic-web \
  --pattern "unetic-web-dist-$VERSION.tar.gz" \
  --pattern SHA256SUMS \
  --dir "$work/web"
(cd "$work/web" && sha256sum -c SHA256SUMS --ignore-missing)
tar -C "$root/feed/unetic-web/source" -xzf "$work/web/unetic-web-dist-$VERSION.tar.gz"
