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
      { pkgs, ... }:
      {
        system.stateVersion = 7;

        environment.systemPackages = [
          pkgs.comchan
          pkgs.unstable.hello
        ];

        myCommon.primaryUser.name = "test";
      }
    )
  ];
  inherit system;
}
