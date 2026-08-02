{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.myCommon.assets = mkOption {
    type = types.lazyAttrsOf types.path;
    default = { };

    example = {
      wallpaper = ./assets/wallpaper.jpg;
      avatar = ./assets/avatar.png;
      logo = ./assets/logo.svg;
    };

    description = ''
      Shared static assets available to NixOS, nix-darwin, and Home Manager
      modules.

      The attribute names are logical identifiers, while the values are paths
      to files or directories.

      This attribute set is intentionally flat and may be extended by multiple
      modules. Public assets can be defined in the common configuration, while
      private or host-specific assets can be added by downstream
      configurations.
    '';
  };
}
