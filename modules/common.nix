# Common nixos/nix-darwin configuration shared between Linux and macOS
{ pkgs, ... }: {
  # Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      enableSyntaxHighlighting = true;
    };

    bash = {
      enableCompletion = true;
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      hack-font
      ubuntu_font_family
      jetbrains-mono
    ];
  };

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  environment.systemPackages = with pkgs; [
    # Nix extensions
    nil
    nixpkgs-fmt
    cachix

    # Rust
    rustup
    sccache

    # Useful utilites
    bat
    ripgrep
    xh
  ];

  environment = {
    variables = {
      EDITOR = "vim";
      RUSTC_WRAPPER = "sccache";
    };
  };
}
