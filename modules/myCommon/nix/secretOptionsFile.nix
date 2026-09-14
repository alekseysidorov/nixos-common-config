{ lib, ... }:

let
  nixModule =
    { config, ... }:

    let
      cfg = config.myCommon.nix;
    in
    {
      options.myCommon.nix.secretOptionsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.externalPath;
        default = null;

        description = ''
          Path to an external nix.conf fragment containing secret Nix options.

          The file is included directly by Nix and should remain outside the
          Nix store. This is intended for options such as access-tokens.
        '';
      };

      config.nix.extraOptions = lib.optionalString (cfg.secretOptionsFile != null) ''
        !include ${cfg.secretOptionsFile}
      '';
    };
in
{
  flake.modules = {
    nixos.myCommon.imports = [ nixModule ];
    darwin.myCommon.imports = [ nixModule ];
    homeManager.myCommon.imports = [ nixModule ];
  };
}
