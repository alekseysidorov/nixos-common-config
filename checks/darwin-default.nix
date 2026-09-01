{
  self,
  inputs,
  system,
  ...
}:
let
  myCommon = {
    gitDefaults = true;

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
    lib: config:
    let
      gitConfig = config.environment.etc.gitconfig.text;
      systemPackageNames = map lib.getName config.environment.systemPackages;
    in
    with config.myCommon;
    [
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
      {
        assertion = lib.hasInfix "[alias]" gitConfig && lib.hasInfix "swp = " gitConfig;
        message = "gitDefaults must write common aliases to /etc/gitconfig";
      }
      {
        assertion = lib.hasInfix ''[filter "lfs"]'' gitConfig;
        message = "gitDefaults must write the Git LFS filter to /etc/gitconfig";
      }
      {
        assertion = !lib.hasInfix "[user]" gitConfig;
        message = "the system Git config must not contain user identity";
      }
      {
        assertion = builtins.all (name: builtins.elem name systemPackageNames) [
          "git-clean-all"
          "git-sweep-all"
        ];
        message = "gitDefaults must install the common Git tools system-wide";
      }
    ];
in
inputs.nix-darwin.lib.darwinSystem {
  modules = [
    self.darwinModules.default
    inputs.home-manager.darwinModules.default
    (
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        system.stateVersion = 7;

        assertions = mkAssertionsFor lib config;

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

              assertions = mkAssertionsFor lib config;

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
