#!/bin/sh

set -eu

manifest=${MANIFEST:-manifest.yml}

value() {
	awk -v key="$1" '$1 == key ":" { print $2 }' "$manifest"
}

validate_tag() {
	repository=$1
	tag=$2

	if ! printf '%s\n' "$tag" | grep -Eq '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'; then
		echo "Invalid tag for $repository: $tag" >&2
		exit 1
	fi

	git ls-remote --exit-code --tags "https://github.com/Unetic/$repository.git" \
		"refs/tags/$tag" >/dev/null
}

case "${1:-}" in
	get)
		value "$2"
		;;
	validate)
		test "$(value openwrt)" = "25.12.5"
		validate_tag unetic-core "$(value unetic-core)"
		validate_tag unetic-cli "$(value unetic-cli)"
		validate_tag unetic-web "$(value unetic-web)"
		openssl pkey -pubin -in keys/unetic.pem -noout
		;;
	*)
		echo "Usage: $0 get <key> | validate" >&2
		exit 2
		;;
esac
