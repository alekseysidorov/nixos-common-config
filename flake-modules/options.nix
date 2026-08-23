{ lib, ... }:

let
  moduleSet = lib.types.attrsOf lib.types.deferredModule;
in
{
  options.flake.nixosModules = lib.mkOption {
    type = moduleSet;
    default = { };
    description = "NixOS modules exported by this flake.";
  };

  options.flake.darwinModules = lib.mkOption {
    type = moduleSet;
    default = { };
    description = "nix-darwin modules exported by this flake.";
  };

  options.flake.homeManagerModules = lib.mkOption {
    type = moduleSet;
    default = { };
    description = "Home Manager modules exported by this flake.";
  };

  options.flake.homeModules = lib.mkOption {
    type = moduleSet;
    default = { };
    description = "Legacy Home Manager modules exported by this flake.";
  };
}
