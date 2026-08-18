# Unetic Packages

Signed APK repository for installing and updating
[Unetic](https://github.com/Unetic) on OpenWrt.

This repository is the single production publisher for:

- `unetic-core`
- `unetic-web`
- `unetic-cli`

Component versions are pinned in [`manifest.yml`](./manifest.yml).

## Repository layout

Current OpenWrt baseline: `25.12.5`.

```text
25.12.5/
├── aarch64_cortex-a53/
│   ├── *.apk
│   └── packages.adb
└── mipsel_24kc/
    ├── *.apk
    └── packages.adb
```

Supported build targets:

| OpenWrt target | Package architecture |
| --- | --- |
| `mediatek/filogic` | `aarch64_cortex-a53` |
| `ramips/mt7621` | `mipsel_24kc` |

## Install

```sh
ARCH="$(cat /etc/apk/arch)"

wget -O /etc/apk/keys/unetic-apk-public.pem \
    https://unetic.github.io/packages/keys/unetic-apk-public.pem

echo "https://unetic.github.io/packages/25.12.5/$ARCH/packages.adb" \
    >> /etc/apk/repositories.d/customfeeds.list

apk update
apk add unetic-core unetic-web
```

Optional CLI:

```sh
apk add unetic-cli
```

## Releases

Publishing is tag-driven.

1. Update component tags in `manifest.yml`.
2. Merge the change into `main`.
3. Create and push a `v*` tag in this repository.
4. GitHub Actions builds both package architectures.
5. APKs and `packages.adb` are signed with the Unetic APK signing key.
6. The repository is deployed to GitHub Pages and attached to the GitHub Release.

Pushes and pull requests to `main` validate the repository but never publish it.

The private signing key is stored only as the `UNETIC_APK_PRIVATE_KEY`
GitHub Actions secret. Only the public key is committed.

## License

GPL-2.0-only.
