#!/bin/bash

set -euo pipefail

: "${SDK_FILE:?SDK_FILE is required}"
: "${SDK_SHA256:?SDK_SHA256 is required}"
: "${OPENWRT_TARGET:?OPENWRT_TARGET is required}"
: "${OPENWRT_SUBTARGET:?OPENWRT_SUBTARGET is required}"
: "${PACKAGE_ARCH:?PACKAGE_ARCH is required}"
: "${RUST_TARGET:?RUST_TARGET is required}"
: "${RUST_TOOLCHAIN:?RUST_TOOLCHAIN is required}"
: "${TOOLCHAIN_PREFIX:?TOOLCHAIN_PREFIX is required}"
: "${UNETIC_APK_PRIVATE_KEY:?UNETIC_APK_PRIVATE_KEY is required}"

openwrt_version=$(scripts/manifest.sh get openwrt)
sdk="$RUNNER_TEMP/openwrt-sdk"
archive="$RUNNER_TEMP/$SDK_FILE"
output="$GITHUB_WORKSPACE/output/$openwrt_version/$PACKAGE_ARCH"

download_sdk() {
	local url="https://downloads.openwrt.org/releases/$openwrt_version/targets/$OPENWRT_TARGET/$OPENWRT_SUBTARGET/$SDK_FILE"

	curl --fail --location --output "$archive" "$url"
	echo "$SDK_SHA256  $archive" | sha256sum --check
	mkdir -p "$sdk"
	tar --zstd --extract --file "$archive" --directory "$sdk" --strip-components=1
}

configure_signing() {
	printf '%s\n' "$UNETIC_APK_PRIVATE_KEY" > "$sdk/private-key.pem"
	chmod 600 "$sdk/private-key.pem"
	cp keys/unetic.pem "$sdk/public-key.pem"

	"$sdk/staging_dir/host/bin/openssl" ec \
		-in "$sdk/private-key.pem" -pubout 2>/dev/null \
		| diff - "$sdk/public-key.pem"

	make -C "$sdk" defconfig
	"$sdk/scripts/config" --enable SIGNED_PACKAGES
	make -C "$sdk" defconfig
}

build_rust() {
	local repository=$1
	local binary=$2
	local package=$3
	local linker cargo_linker

	linker=$(find "$sdk/staging_dir" -type f -name "$TOOLCHAIN_PREFIX-gcc" -print -quit)
	test -n "$linker"
	cargo_linker="CARGO_TARGET_$(echo "$RUST_TARGET" | tr '[:lower:]-' '[:upper:]_')_LINKER"

	(
		cd "sources/$repository"
		export "$cargo_linker=$linker"
		export RUSTFLAGS="-C target-feature=-crt-static"

		if [ "${RUST_BUILD_STD:-false}" = true ]; then
			cargo "+$RUST_TOOLCHAIN" build --locked --release \
				--target "$RUST_TARGET" -Z build-std=std,panic_abort
		else
			cargo "+$RUST_TOOLCHAIN" build --locked --release --target "$RUST_TARGET"
		fi
	)

	prepare_package "$repository" "$package"
	cp "sources/$repository/target/$RUST_TARGET/release/$binary" \
		"$sdk/package/$package/source/openwrt-binary"
}

build_web() {
	(
		cd sources/unetic-web
		npm ci
		npm run build
	)

	prepare_package unetic-web unetic-web
	cp -R sources/unetic-web/dist "$sdk/package/unetic-web/source/"
}

prepare_package() {
	local repository=$1
	local package=$2
	local destination="$sdk/package/$package"

	mkdir -p "$destination/source"
	cp -R "sources/$repository/openwrt/." "$destination/"
	cp "sources/$repository/LICENSE" "$destination/source/"
	cp "sources/$repository/Cargo.toml" "$destination/source/" 2>/dev/null || true
	cp "sources/$repository/package.json" "$destination/source/" 2>/dev/null || true
}

collect_repository() {
	mkdir -p "$output"

	for package in unetic-core unetic-cli unetic-web; do
		find "$sdk/bin" -type f -name "$package-*.apk" -exec cp {} "$output/" \;
	done

	test "$(find "$output" -maxdepth 1 -name '*.apk' | wc -l)" -eq 3
	(
		cd "$output"
		"$sdk/staging_dir/host/bin/apk" mkndx \
			--root "$sdk" \
			--keys-dir "$sdk" \
			--allow-untrusted \
			--sign "$sdk/private-key.pem" \
			--output packages.adb \
			./*.apk
	)
}

download_sdk
configure_signing
build_rust unetic-core unetic-core unetic-core
build_rust unetic-cli unetic-cli unetic-cli
build_web
make -C "$sdk" package/unetic-core/compile package/unetic-cli/compile package/unetic-web/compile V=s
collect_repository
