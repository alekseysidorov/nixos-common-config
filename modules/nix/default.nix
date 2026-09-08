{ ... }:

let
  # These settings are part of the baseline contract of myCommon.
  #
  # The configuration itself is flake-based, so nix-command and flakes are
  # requirements rather than optional features.
  commonNixSettingsModule = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # NixOS administrators are members of wheel. Trust the administrative group
  # rather than coupling the common configuration to a particular user name.
  nixosModule = {
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };

  # On macOS administrative users belong to admin rather than wheel.
  darwinModule = {
    nix.settings.trusted-users = [
      "root"
      "@admin"
    ];
  };
in
{
  imports = [
    ./extraSubstituters.nix
    ./home
  ];

  flake.modules = {
    nixos.myCommon.imports = [
      commonNixSettingsModule
      nixosModule
    ];

    darwin.myCommon.imports = [
      commonNixSettingsModule
      darwinModule
    ];

    homeManager.myCommon.imports = [
      commonNixSettingsModule
    ];
  };
}
