#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 5 ]; then
  echo "usage: $0 <package-name> <version> <sdk-dir> <payload-dir> <output-dir>" >&2
  exit 2
fi

package_name=$1
version=$2
sdk=$3
payload=$4
output=$5
package_dir="$sdk/package/$package_name"

case "$package_name" in
  unetic-core|unetic-cli|unetic-web) ;;
  *) echo "unsupported package: $package_name" >&2; exit 2 ;;
esac

test -d "feed/$package_name"
test -d "$payload"
test -d "$sdk"

rm -rf "$package_dir"
mkdir -p "$package_dir/source" "$output"
cp -R "feed/$package_name/." "$package_dir/"
cp -R "$payload/." "$package_dir/source/"
if [[ -f "feed/$package_name/LICENSE" ]]; then
  cp "feed/$package_name/LICENSE" "$package_dir/source/LICENSE"
fi
printf '%s\n' "$version" > "$package_dir/source/VERSION"

# Keep packaging deterministic and make stale SDK outputs impossible to pick up.
find "$sdk/bin" -type f -name "$package_name-*.apk" -delete 2>/dev/null || true

make -C "$sdk" defconfig
make -C "$sdk" "package/$package_name/clean" >/dev/null
make -C "$sdk" "package/$package_name/compile" -j2 V=s

mapfile -t apks < <(find "$sdk/bin" -type f -name "$package_name-*.apk" -print)
if [ "${#apks[@]}" -ne 1 ]; then
  echo "expected exactly one APK for $package_name, found ${#apks[@]}" >&2
  printf '%s\n' "${apks[@]:-}" >&2
  exit 1
fi

cp "${apks[0]}" "$output/"
echo "Built $(basename "${apks[0]}")"
