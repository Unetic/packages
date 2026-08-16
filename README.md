# Unetic packages

Production APK repository for Unetic on OpenWrt 25.12.5.

`manifest.yml` pins the component release tags. Pull requests and pushes to
`main` only validate the manifest and public key. Publishing starts exclusively
when a `v*` tag is pushed in this repository.

Published repositories:

```text
25.12.5/aarch64_cortex-a53/packages.adb
25.12.5/mipsel_24kc/packages.adb
```

Each directory also contains `unetic-core`, `unetic-cli`, and `unetic-web` APKs.
The signed repository index authenticates the APKs with the public key in
`keys/unetic-apk-public.pem`.

The `mediatek/filogic` SDK supplies `aarch64_cortex-a53`. The `ramips/mt7621`
SDK supplies `mipsel_24kc`; Rust's standard library for that tier-3 target is
built from the pinned nightly toolchain because rustup does not distribute it.

## Release

1. Update component tags in `manifest.yml`.
2. Merge the validated change into `main`.
3. Tag the packages repository, for example `v0.1.0`, and push the tag.

The `UNETIC_APK_PRIVATE_KEY` Actions secret must contain the PEM private key
matching `keys/unetic-apk-public.pem`. GitHub Pages must use GitHub Actions as
its source.

On a router, install the public key under `/etc/apk/keys/`, add the appropriate
`packages.adb` URL to `/etc/apk/repositories.d/customfeeds.list`, then run:

```sh
wget -O /etc/apk/keys/unetic-apk-public.pem \
  https://unetic.github.io/packages/keys/unetic-apk-public.pem
echo 'https://unetic.github.io/packages/25.12.5/aarch64_cortex-a53/packages.adb' \
  >> /etc/apk/repositories.d/customfeeds.list
apk update
apk add unetic-core unetic-cli unetic-web
```

Use `mipsel_24kc` instead of `aarch64_cortex-a53` for an mt7621 router.
