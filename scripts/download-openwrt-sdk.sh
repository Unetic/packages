#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 6 ]; then
  echo "usage: $0 <openwrt-version> <target> <subtarget> <sdk-file> <sdk-sha256> <destination>" >&2
  exit 2
fi

openwrt_version=$1
target=$2
subtarget=$3
sdk_file=$4
sdk_sha256=$5
destination=$6
archive="${RUNNER_TEMP:-/tmp}/$sdk_file"
url="https://downloads.openwrt.org/releases/$openwrt_version/targets/$target/$subtarget/$sdk_file"

rm -rf "$destination"
mkdir -p "$destination"

curl --fail --location --retry 3 --retry-delay 2 --output "$archive" "$url"
echo "$sdk_sha256  $archive" | sha256sum --check

tar --zstd --extract --file "$archive" --directory "$destination" --strip-components=1

test -x "$destination/staging_dir/host/bin/apk"
echo "OpenWrt SDK ready: $openwrt_version $target/$subtarget"
