# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: adapt this
asdf plugin test mcp-proxy https://github.com/awea/asdf-mcp-proxy.git "mcp-proxy --help"
```

Tests are automatically run in GitHub Actions on push and PR.
