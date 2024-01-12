# Common nixos/nix-darwin configuration shared between Linux and macOS
{ pkgs, flake, ... }: {
  # Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };

  # Some common tweaks for nix packages
  nixpkgs = {
    config.allowUnfree = true;
    # Some additional overlays.
    overlays = [
      # Workaround for the not being able to download a file.
      # https://rycee.net/nmd.tar.gz
      flake.inputs.nmd.overlays.default
      # Some customization.
      (final: prev: {
        # Unstable packages
        unstable = import flake.inputs.nixpkgs-unstable {
          inherit (pkgs) system;
          config.allowUnfree = true;
        };
      })
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
}
