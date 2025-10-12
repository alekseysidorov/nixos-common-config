# Common fonts
{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    hack-font
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.zed-mono
    nerd-fonts.roboto-mono
    nerd-fonts.inconsolata
    source-code-pro
    ubuntu_font_family
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    inter
    roboto
    roboto-mono
  ];
}
