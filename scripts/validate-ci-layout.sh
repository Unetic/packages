#!/usr/bin/env bash
set -euo pipefail

jq -e '
  .schema == 2 and
  .openwrt == "25.12" and
  (.architectures | type == "array" and length == 2) and
  (all(.architectures[]; type == "string" and length > 0)) and
  ([.architectures[]] | unique | length == 2)
' config/targets.json >/dev/null

test -s keys/unetic-apk-v1.pem
openssl pkey -pubin -in keys/unetic-apk-v1.pem -noout

for package in unetic-core unetic-cli unetic-web; do
  test -s "feed/$package/Makefile"
done

grep -q 'PKGARCH:=all' feed/unetic-web/Makefile
grep -q 'openwrt-binary' feed/unetic-core/Makefile
grep -q 'openwrt-binary' feed/unetic-cli/Makefile

echo "CI/deployment layout is valid"
