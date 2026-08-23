{
  self,
  inputs,
  system,
  ...
}:

inputs.nix-darwin.lib.darwinSystem {
  modules = [
    self.darwinModules.default
    (
      { ... }:
      {
        system.stateVersion = 7;

        myCommon.primaryUser.name = "test";
      }
    )
  ];
  inherit system;
}
