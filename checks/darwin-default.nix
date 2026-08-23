{
  self,
  inputs,
  system,
  ...
}:
let
  myCommon = {
    primaryUser = {
      name = "test";
    };
    shared = {
      foo = "bar";
    };

    nix = {
      knownSubstituters = {
        cachix = {
          uri = "https://example.cachix.org";
          publicKey = "example.cachix.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };
      enabledSubstituters = [ "cachix" ];
    };
  };
in
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

        inherit myCommon;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.test =
            { ... }:
            {
              home.stateVersion = "26.05";

              imports = [
                self.homeManagerModules.default
              ];

              inherit myCommon;
            };
        };

      }
    )
  ];
  inherit system;
}
