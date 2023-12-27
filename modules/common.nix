# Common nixos/nix-darwin configuration shared between Linux and macOS
{ pkgs, ... }: {
  # Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };

  # Some common tweaks for nix packages
  nixpkgs = {
    config.allowUnfree = true;
    # Some additional overlays
    overlays = [

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
