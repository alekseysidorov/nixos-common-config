# Shell settings and integrations
{ ... }:
{
  home.shell.enableShellIntegration = true;
  myCommon.home.interactiveShell = "nushell";

  programs = {
    starship = {
      enable = true;
      presets = [ "pure-preset" ];
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
