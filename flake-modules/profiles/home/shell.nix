# Shell settings and integrations
{ ... }:
{
  myCommon.home.enableNushellIntegration = true;

  programs = {
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
