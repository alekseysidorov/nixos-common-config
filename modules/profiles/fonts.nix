{ ... }:

let
  fontPackages =
    pkgs: with pkgs; [
      # Compatibility.
      corefonts

      # Sans-serif.
      inter
      roboto
      atkinson-hyperlegible-next
      ibm-plex

      # Serif.
      roboto-serif
      roboto-slab

      # Monospace.
      hack-font
      jetbrains-mono
      source-code-pro
      roboto-mono
      cascadia-code
      iosevka
      maple-mono

      # Nerd Fonts.
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg

      # Fallback and multilingual coverage.
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
in
{
  flake.modules = {
    nixos.fonts =
      { pkgs, ... }:
      {
        fonts = {
          packages = fontPackages pkgs;
          enableDefaultPackages = true;
        };
      };

    darwin.fonts =
      { pkgs, ... }:
      {
        fonts.packages = fontPackages pkgs;
      };
  };
}
