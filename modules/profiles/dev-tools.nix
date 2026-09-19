# Development tooling useful across repositories regardless of their primary
# implementation language.
#
# Language-specific toolchains belong to dedicated profiles such as rustDev and
# nixDev. This profile contains editor integration, formatters, linters, and
# repository-wide diagnostics that are useful across otherwise unrelated
# projects.

{ ... }:

{
  flake.modules.homeManager.devTools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Structured data and configuration files.
        yaml-language-server
        vscode-json-languageserver
        # TOML language server, formatter, and linter.
        tombi
        # Documentation and prose.
        #
        # marksman provides Markdown navigation, completion, references, and
        # workspace awareness; markdownlint handles document style separately.
        marksman
        markdownlint-cli2
        # Spelling and typo diagnostics.
        #
        # Keep both the LSP and CLI available: the former is editor-facing,
        # while the latter is useful for repository-wide checks and CI.
        typos-lsp
        typos
        # Package manifest metadata.
        #
        # Provides editor diagnostics and version information for dependencies
        # across multiple package ecosystems rather than being tied to Cargo.
        package-version-server
        # POSIX shell and Bash tooling.
        #
        # The language server provides editor features, while shellcheck and
        # shfmt remain useful independently from any particular editor.
        bash-language-server
        shellcheck
        shfmt
        # Nushell tooling.
        #
        # Nushell itself provides its language server; these complement it with
        # standalone formatting and static analysis.
        nufmt
        nu-lint
        # CI configuration.
        #
        # actionlint understands GitHub Actions semantics in addition to plain
        # YAML syntax, including expressions, jobs, inputs, and dependencies.
        actionlint
        # Repository-wide formatting policy.
        #
        # Checks files against .editorconfig independently of editor support.
        editorconfig-checker
      ];
    };
}
