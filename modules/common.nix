# Common nixos/nix-darwin configuration shared between Linux and macOS
{ pkgs, inputs, ... }: {
  # Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    allow-import-from-derivation = true;
  };

  # Some common tweaks for nix packages
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (
        import ./../overlay.nix {
          nixpkgs-unstable = inputs.nixpkgs-unstable;
          config.allowUnfree = true;
        }
      )
    ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      enableSyntaxHighlighting = true;
    };

    bash = {
      completion.enable = true;
    };
  };

  # Common fonts
  fonts = {
    packages = with pkgs.unstable; [
      hack-font
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.inconsolata
      source-code-pro
      ubuntu_font_family
    ];
  };
}
