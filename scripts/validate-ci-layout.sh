#!/usr/bin/env bash
set -euo pipefail

jq -e '.schema == 1' config/targets.json >/dev/null
jq -e '.apk_releases | type == "array" and length > 0' config/targets.json >/dev/null

# Every OpenWrt release must have targets and all matrix fields required by the workflows.
jq -e '
  all(.apk_releases[];
    (.openwrt | type == "string" and length > 0) and
    (.targets | type == "array" and length > 0) and
    all(.targets[];
      ([ .architecture, .target, .subtarget, .sdk_file, .sdk_sha256,
         .rust_target, .rust_toolchain, .toolchain_prefix ]
       | all(.[]; type == "string" and length > 0)) and
      (.rust_build_std | type == "boolean")
    )
  )
' config/targets.json >/dev/null

# No duplicate OpenWrt/version architecture pair is allowed.
pairs=$(jq -r '.apk_releases[] as $r | $r.targets[] | "\($r.openwrt)/\(.architecture)"' config/targets.json)
test "$(printf '%s\n' "$pairs" | sort | uniq -d | wc -l)" -eq 0

test -s keys/unetic-apk-v1.pem
openssl pkey -pubin -in keys/unetic-apk-v1.pem -noout

for package in unetic-core unetic-cli unetic-web; do
  test -s "feed/$package/Makefile"
done

grep -q 'PKGARCH:=all' feed/unetic-web/Makefile
grep -q 'openwrt-binary' feed/unetic-core/Makefile
grep -q 'openwrt-binary' feed/unetic-cli/Makefile

echo "CI/deployment layout is valid"
