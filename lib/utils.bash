#!/usr/bin/env bash

set -euo pipefail

# GitHub repository for the Rust MCP proxy with prebuilt binaries
GH_REPO="https://github.com/tidewave-ai/mcp_proxy_rust"
TOOL_NAME="mcp-proxy"
TOOL_TEST="mcp-proxy --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if mcp-proxy is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if mcp-proxy has other means of determining installable versions.
	list_github_tags
}

get_platform() {
	local os arch
	os="$(uname -s)"
	arch="$(uname -m)"

	case "$os" in
	Darwin)
		case "$arch" in
		x86_64) echo "x86_64-apple-darwin" ;;
		arm64) echo "aarch64-apple-darwin" ;;
		*) fail "Unsupported macOS architecture: $arch" ;;
		esac
		;;
	Linux)
		case "$arch" in
		x86_64) echo "x86_64-unknown-linux-musl" ;;
		aarch64) echo "aarch64-unknown-linux-musl" ;;
		arm64) echo "aarch64-unknown-linux-musl" ;;
		*) fail "Unsupported Linux architecture: $arch" ;;
		esac
		;;
	MINGW* | MSYS* | CYGWIN*)
		case "$arch" in
		x86_64) echo "x86_64-pc-windows-msvc" ;;
		*) fail "Unsupported Windows architecture: $arch" ;;
		esac
		;;
	*)
		fail "Unsupported operating system: $os"
		;;
	esac
}

get_file_extension() {
	local os
	os="$(uname -s)"
	case "$os" in
	MINGW* | MSYS* | CYGWIN*) echo "zip" ;;
	*) echo "tar.gz" ;;
	esac
}

download_release() {
	local version filename platform extension url
	version="$1"
	filename="$2"
	platform="$(get_platform)"
	extension="$(get_file_extension)"

	url="$GH_REPO/releases/download/v${version}/mcp-proxy-${platform}.${extension}"

	echo "* Downloading $TOOL_NAME release $version for platform $platform..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		# Copy the pre-built binary from the download path
		local binary_name="mcp-proxy"
		if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* || "$(uname -s)" == CYGWIN* ]]; then
			binary_name="mcp-proxy.exe"
		fi

		if [ -f "$ASDF_DOWNLOAD_PATH/$binary_name" ]; then
			cp "$ASDF_DOWNLOAD_PATH/$binary_name" "$install_path/" || fail "Failed to copy binary"
		elif [ -f "$ASDF_DOWNLOAD_PATH/mcp-proxy" ]; then
			cp "$ASDF_DOWNLOAD_PATH/mcp-proxy" "$install_path/" || fail "Failed to copy binary"
		else
			fail "Binary not found in download path"
		fi

		chmod +x "$install_path/mcp-proxy" 2>/dev/null || true # chmod may fail on Windows, ignore

		# Verify the binary works
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
