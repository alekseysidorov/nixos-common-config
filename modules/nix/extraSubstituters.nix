{ ... }:

let
  optionsModule =
    { lib, ... }:

    let
      inherit (lib) mkOption types;

      substituterType = types.submodule {
        options = {
          uri = mkOption {
            type = types.str;
            description = "URI of the Nix binary cache.";
          };

          publicKey = mkOption {
            type = types.str;
            description = "Public signing key of the Nix binary cache.";
          };

          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable this binary cache.";
          };
        };
      };
    in
    {
      options.myCommon.nix.extraSubstituters = mkOption {
        type = types.lazyAttrsOf substituterType;
        default = { };

        description = ''
          Named Nix binary caches.

          Definitions may be contributed by multiple modules. A cache is only
          added to the Nix configuration when its `enable` option is true.
        '';
      };
    };

  configModule =
    { config, lib, ... }:

    let
      substituters = lib.filterAttrs (
        _name: substituter: substituter.enable
      ) config.myCommon.nix.extraSubstituters;

      values = builtins.attrValues substituters;
    in
    {
      nix.settings = lib.optionalAttrs (values != [ ]) {
        extra-substituters = map (substituter: substituter.uri) values;

        extra-trusted-public-keys = map (substituter: substituter.publicKey) values;
      };
    };
in
{
  flake.modules = {
    nixos.myCommon.imports = [
      optionsModule
      configModule
    ];

    darwin.myCommon.imports = [
      optionsModule
      configModule
    ];

    homeManager.myCommon.imports = [
      optionsModule
      configModule
    ];
  };
}
