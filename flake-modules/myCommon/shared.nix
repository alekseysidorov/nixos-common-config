{ ... }:
let
  optionsModule =
    { lib, ... }:
    let
      inherit (lib) mkOption types;
    in
    {
      key = "myCommon/shared/config";

      options.myCommon.shared = mkOption {
        type = types.attrsOf (types.either types.path types.attrs);
        default = { };

        example = {
          wallpaper = ./assets/wallpaper.jpg;
          avatar = ./assets/avatar.png;
          logo = ./assets/logo.svg;
          config = {
            key = "value";
            nested = {
              option = true;
            };
          };
        };

        description = ''
          A flexible attribute set for shared settings, available to NixOS,
          nix-darwin, and Home Manager modules.

          The attribute names are logical identifiers, while the values can be
          paths (for static assets) or nested attribute sets (for configuration).

          This attribute set is intentionally flat and may be extended by multiple
          modules. Public settings can be defined in the common configuration,
          while private or host-specific settings can be added by downstream
          configurations.
        '';
      };
    };
in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
    ];

    darwinModules.myCommon.imports = [
      optionsModule
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
    ];
  };
}
