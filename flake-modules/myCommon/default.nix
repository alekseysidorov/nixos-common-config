{ config, ... }:

{
  imports = [
    ./primaryUser.nix
    ./extraSubstituters.nix
    ./git.nix
    ./shared.nix
  ];

  flake = {
    darwinModules.default.imports = [
      config.flake.darwinModules.myCommon
    ];

    nixosModules.default.imports = [
      config.flake.nixosModules.myCommon
    ];

    homeManagerModules.default.imports = [
      config.flake.homeManagerModules.myCommon
    ];
  };
}
