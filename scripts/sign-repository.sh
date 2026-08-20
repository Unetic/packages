#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <sdk-dir> <repository-dir> <private-key-file>" >&2
  exit 2
fi

sdk=$1
repository=$2
private_key=$3
public_key="keys/unetic-apk-v1.pem"

test -x "$sdk/staging_dir/host/bin/apk"
test -s "$private_key"
test -s "$public_key"
test -n "$(find "$repository" -maxdepth 1 -type f -name '*.apk' -print -quit)"

mkdir -p "$sdk/unetic-signing"
cp "$public_key" "$sdk/unetic-signing/unetic-apk-v1.pem"
cp "$private_key" "$sdk/unetic-signing/private-key.pem"
chmod 600 "$sdk/unetic-signing/private-key.pem"

(
  cd "$repository"
  "$sdk/staging_dir/host/bin/apk" mkndx \
    --root "$sdk" \
    --keys-dir "$sdk/unetic-signing" \
    --allow-untrusted \
    --sign "$sdk/unetic-signing/private-key.pem" \
    --output packages.adb \
    ./*.apk
)

test -s "$repository/packages.adb"
echo "Signed repository index: $repository/packages.adb"
