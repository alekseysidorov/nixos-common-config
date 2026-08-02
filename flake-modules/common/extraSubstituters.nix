{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.myCommon.nix;

  substituterType = types.submodule {
    options = {
      uri = mkOption {
        type = types.str;

        description = ''
          URI of the Nix binary cache.

          The value is added to `nix.settings.extra-substituters` when this
          substituter is enabled.
        '';
      };

      publicKey = mkOption {
        type = types.str;

        description = ''
          Public signing key of the Nix binary cache.

          The value is added to
          `nix.settings.extra-trusted-public-keys` when this substituter is
          enabled.
        '';
      };
    };
  };

  enabledNames =
    if cfg.enabledSubstituters == "all" then
      builtins.attrNames cfg.knownSubstituters
    else
      cfg.enabledSubstituters;

  enabled = map (name: cfg.knownSubstituters.${name}) enabledNames;
in
{
  options.myCommon.nix = {
    knownSubstituters = mkOption {
      type = types.lazyAttrsOf substituterType;
      default = { };

      example = {
        cachix = {
          uri = "https://example.cachix.org";
          publicKey = "example.cachix.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };

      description = ''
        Named definitions of known Nix binary caches.

        Each entry contains the cache URI and its public signing key. Entries
        may be added by multiple modules. Defining an entry does not enable it;
        use `myCommon.nix.enabledSubstituters` to select caches for the current
        system.
      '';
    };

    enabledSubstituters = mkOption {
      type = types.either (types.enum [ "all" ]) (types.listOf types.str);

      default = [ ];

      example = [
        "cachix"
        "private"
      ];

      description = ''
        Names of entries from `myCommon.nix.knownSubstituters` to enable on
        the current system.

        Set this option to `"all"` to enable every known substituter. The
        default empty list enables none.
      '';
    };
  };

  config = {
    assertions = map (name: {
      assertion = builtins.hasAttr name cfg.knownSubstituters;
      message = ''
        Unknown substituter `${name}` listed in
        `myCommon.nix.enabledSubstituters`.
      '';
    }) enabledNames;

    nix.settings = {
      extra-substituters = map (substituter: substituter.uri) enabled;

      extra-trusted-public-keys = map (substituter: substituter.publicKey) enabled;
    };
  };
}
