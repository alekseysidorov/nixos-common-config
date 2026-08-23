{
  self,
  inputs,
  system,
  ...
}:

inputs.nix-darwin.lib.darwinSystem {
  modules = [
    self.darwinModules.default
    self.darwinModules.myCommon
    inputs.home-manager.darwinModules.default
    (
      { pkgs, ... }:
      {
        system.stateVersion = 7;

        environment.systemPackages = [
          pkgs.comchan
          pkgs.unstable.hello
        ];

        myCommon.primaryUser.name = "test";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.test =
            { ... }:
            {
              home.stateVersion = "26.05";
            };
        };

      }
    )
  ];
  inherit system;
}
