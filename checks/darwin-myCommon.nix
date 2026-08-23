{
  self,
  inputs,
  system,
  ...
}:

inputs.nix-darwin.lib.darwinSystem {
  modules = [
    self.darwinModules.myCommon
    (
      { ... }:
      {
        system.stateVersion = 7;

        myCommon.primaryUser.name = "test";

        myCommon.shared = {
          foo = "bar";
        };
      }
    )
  ];
  inherit system;
}
