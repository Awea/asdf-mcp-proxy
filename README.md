<div align="center">

# asdf-mcp-proxy [![Build](https://github.com/awea/asdf-mcp-proxy/actions/workflows/build.yml/badge.svg)](https://github.com/awea/asdf-mcp-proxy/actions/workflows/build.yml) [![Lint](https://github.com/awea/asdf-mcp-proxy/actions/workflows/lint.yml/badge.svg)](https://github.com/awea/asdf-mcp-proxy/actions/workflows/lint.yml)

[mcp-proxy](https://github.com/tidewave-ai/mcp_proxy_rust) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `unzip` (for Windows users)

This plugin downloads pre-built binaries for:
- **macOS**: Intel (x86_64) and Apple Silicon (aarch64/arm64)
- **Linux**: x86_64 and aarch64 (uses musl for better compatibility)
- **Windows**: x86_64

# Install

Plugin:

```shell
asdf plugin add mcp-proxy https://github.com/awea/asdf-mcp-proxy.git
```

mcp-proxy:

```shell
# Show all installable versions
asdf list all mcp-proxy

# Install specific version
asdf install mcp-proxy latest

# Set a version globally (on your ~/.tool-versions file)
asdf set -u mcp-proxy latest

# Now mcp-proxy commands are available
mcp-proxy --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/awea/asdf-mcp-proxy/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Awea](https://github.com/awea/)
