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

  mkAssertionsFor =
    config: with config.myCommon; [
      {
        assertion = primaryUser.name == "test";
        message = "primaryUser.name must be configured";
      }
      {
        assertion = primaryUser.paths.homeDirectory == "/Users/test";
        message = "primaryUser.homeDirectory must be calculated";
      }
      {
        assertion = primaryUser.paths.sopsAgeKeyFile == "/Users/test/.config/sops/age/keys.txt";
        message = "primaryUser.sopsAgeKeyfile must be calculated";
      }
    ];
in
inputs.nix-darwin.lib.darwinSystem {
  modules = [
    self.darwinModules.default
    self.darwinModules.myCommon
    inputs.home-manager.darwinModules.default
    (
      { pkgs, config, ... }:
      {
        system.stateVersion = 7;

        assertions = mkAssertionsFor config;

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

              assertions = mkAssertionsFor config;

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
