# Extra development stuff
{ pkgs, lib, ... }: {

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs.unstable; [
    # Rust
    cargo-criterion
    cargo-deny
    cargo-machete
    cargo-nextest
    cargo-watch
    criterion-table
    markdownlint-cli
    shellcheck
    taplo
    typos
  ];

  # Common zed editor configuration
  programs.zed-editor = {
    userSettings = lib.mkMerge {
      ui_font_size = 15;
      buffer_font_size = 13;
      terminal.shell.program = "nu";
      # theme = "Fleet Dark";
      theme = "siri";

      lsp = {
        nil.settings = {
          formatting.command = "nixpkgs-fmt";
          flake = {
            autoArchive = true;
            autoEvalInputs = true;
            nixpkgsInputsName = "nixpkgs";
          };
        };
      };
    };

    extensions = [
      "cargo-appraiser"
      "cargo-tom"
      "dockerfile"
      "fleet-themes"
      "github-dark-default"
      "nix"
      "nu"
      "markdown-oxide"
      "siri"
    ];
  };
}
