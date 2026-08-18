# Unetic Packages

`Unetic/packages` is the single production deployment repository for Unetic on OpenWrt APK-based releases.

## Release contract

A packages release `vX.Y.Z` consumes the already successful component releases with exactly the same tag:

- `Unetic/unetic-core` `vX.Y.Z`
- `Unetic/unetic-cli` `vX.Y.Z`
- `Unetic/unetic-web` `vX.Y.Z`

There is no second version manifest to drift out of sync.

Component repositories build and publish immutable release inputs. Rust repositories publish one binary for every OpenWrt/architecture tuple in `config/targets.json`. Web publishes one `unetic-web-dist-X.Y.Z.tar.gz`; Angular is never rebuilt by `packages`.

`packages` wraps those release inputs into APKs, signs each `packages.adb` repository index, deploys the repository tree to GitHub Pages, and attaches APK/repository artifacts to the GitHub Release.

## Supported APK matrix

The source of truth is `config/targets.json`. Adding an APK-capable OpenWrt release or architecture is a data change there. The Angular dist is independent of this matrix and remains one build per Unetic version.

Current repository layout on Pages:

```text
<openwrt-version>/
  <apk-architecture>/
    unetic-core-*.apk
    unetic-cli-*.apk
    unetic-web-*.apk
    packages.adb
keys/
  unetic-apk-v1.pem
```

## Install

For OpenWrt `25.12.5`:

```sh
ARCH="$(cat /etc/apk/arch)"

wget -O /etc/apk/keys/unetic-apk-v1.pem \
  https://unetic.github.io/packages/keys/unetic-apk-v1.pem

echo "https://unetic.github.io/packages/25.12.5/$ARCH/packages.adb" \
  >> /etc/apk/repositories.d/customfeeds.list

apk update
apk add unetic-core unetic-web
# optional
apk add unetic-cli
```

## CI/CD behavior

Branch pushes and pull requests only run non-publishing CI. Tag/release workflows are separate.

A component tag or published release `vX.Y.Z` runs CI first. Only after CI succeeds are release assets created/updated. `workflow_dispatch` exists so an old tag can be republished after a workflow migration without deleting and recreating the tag.

A `packages` tag or published release `vX.Y.Z` first verifies all three component releases and checksums. It then builds APKs, deploys Pages, and finally marks the GitHub Release complete by uploading `unetic-packages-X.Y.Z-manifest.json`.

## Secret

The only production signing secret is repository secret `UNETIC_APK_PRIVATE_KEY` in `Unetic/packages`. The matching public key is committed as `keys/unetic-apk-v1.pem`.
