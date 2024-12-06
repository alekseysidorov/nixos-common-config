# Common nixos/nix-darwin configuration shared between Linux and macOS
{ pkgs, flake, ... }: {
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
          nixpkgs-unstable = flake.nixpkgs-unstable;
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

  fonts = {
    packages = with pkgs; [
      hack-font
      ubuntu_font_family
      jetbrains-mono
      fira-code-nerdfont
    ];
  };
}
