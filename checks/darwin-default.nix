{
  self,
  inputs,
  system,
  ...
}:
let
  myCommon = {
    enableGitIntegration = true;

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

  homeMyCommon = myCommon // {
    home.enableNushellIntegration = true;
  };

  defaultHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { inherit system; };
    modules = [
      self.homeManagerModules.myCommon
      {
        home = {
          username = "default";
          homeDirectory = "/Users/default";
          stateVersion = "26.05";
        };
      }
    ];
  };

  disabledIntegrationHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { inherit system; };
    modules = [
      self.homeManagerModules.myCommon
      {
        home = {
          username = "no-integration";
          homeDirectory = "/Users/no-integration";
          stateVersion = "26.05";
          shell.enableShellIntegration = false;
        };
        myCommon.home.enableNushellIntegration = true;
      }
    ];
  };

  disabledDarwin = inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    modules = [
      self.darwinModules.myCommon
      {
        system.stateVersion = 7;
      }
    ];
  };

  nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.default
      {
        system.stateVersion = "26.05";
        myCommon.primaryUser.name = "test";
        users.users.test.isNormalUser = true;
      }
    ];
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
        message = "enableGitIntegration must write common aliases to /etc/gitconfig";
      }
      {
        assertion = lib.hasInfix ''[filter "lfs"]'' gitConfig;
        message = "enableGitIntegration must write the Git LFS filter to /etc/gitconfig";
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
        message = "enableGitIntegration must install the common Git tools system-wide";
      }
      {
        assertion = nixos.config.users.users.test.shell == nixos.pkgs.bashInteractive;
        message = "the NixOS primary user's login shell must remain Bash";
      }
      {
        assertion =
          config.myCommon.home.enableNushellIntegration
          && config.programs.fish.enable
          && nixos.config.programs.fish.enable
          && !disabledDarwin.config.programs.fish.enable;
        message = "NixOS and nix-darwin must provide Fish for the Nushell completion backend";
      }
      {
        assertion =
          !defaultHome.config.myCommon.home.enableNushellIntegration
          && !defaultHome.config.programs.nushell.enable
          && defaultHome.config.programs.bash.initExtra == "";
        message = "the disabled Nushell integration must not alter shell behavior";
      }
      {
        assertion =
          disabledIntegrationHome.config.programs.nushell.enable
          && !lib.hasInfix "/bin/nu" (
            builtins.unsafeDiscardStringContext disabledIntegrationHome.config.programs.bash.initExtra
          );
        message = "disabling shell integration must suppress the Bash trampoline";
      }
    ];

  mkHomeAssertions =
    lib: config:
    let
      trampoline = builtins.unsafeDiscardStringContext config.programs.bash.initExtra;
    in
    [
      {
        assertion =
          config.programs.bash.enable && config.programs.nushell.enable && config.programs.zsh.enable;
        message = "the shell profile must enable Bash, Nushell, and Zsh";
      }
      {
        assertion =
          lib.hasInfix "exec " trampoline
          && lib.hasInfix "/bin/nu" trampoline
          && lib.hasInfix "-t 0 && -t 1" trampoline
          && !lib.hasInfix "$-" trampoline;
        message = "interactive Bash must receive the minimal Nushell trampoline";
      }
      {
        assertion =
          config.programs.starship.presets == [ "pure-preset" ]
          && config.programs.starship.settings.character.success_symbol == "[➜](purple)"
          && config.programs.starship.settings.env_var.variable == "PROMPT_NAME";
        message = "the shell profile must apply the intended overrides to the Starship pure preset";
      }
      {
        assertion =
          !config.programs.carapace.enable
          && config.programs.nushell.settings.completions.external.enable
          && lib.hasInfix "/custom-completions/just/just-completions.nu" config.programs.nushell.extraConfig
          && config.programs.starship.enableBashIntegration
          && config.programs.starship.enableNushellIntegration
          && config.programs.starship.enableZshIntegration
          && config.programs.direnv.enableBashIntegration
          && config.programs.direnv.enableNushellIntegration
          && config.programs.direnv.enableZshIntegration;
        message = "the shell profile must provide Fish plus native Just completions";
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
            { config, ... }:
            {
              home.stateVersion = "26.05";

              assertions = mkHomeAssertions lib config;

              imports = [
                self.homeManagerModules.default
              ];

              myCommon = homeMyCommon;
            };
        };
      }
    )
  ];
  inherit system;
}
