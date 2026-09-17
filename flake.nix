{
  description = "Common parts of NixOS configuration";

  inputs = {
    # Nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # System configuration
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development
    nix-devtools = {
      url = "github:alekseysidorov/nix-devtools";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        inherit (inputs.nixpkgs) lib;

        # Build this repository's package namespace against a given package set.
        localPackagesFor =
          pkgs:
          lib.filesystem.packagesFromDirectoryRecursive {
            directory = ./pkgs;

            callPackage = lib.callPackageWith (
              pkgs
              // {
                inherit (inputs)
                  crane
                  rust-advisory-db
                  ;
              }
            );
          };

        localOverlay = final: _prev: localPackagesFor final;

        # Expose an unstable package universe with the same common capabilities.
        unstableOverlay = final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.stdenv.hostPlatform.system;
            config = final.config;

            overlays = [
              inputs.nix-devtools.overlays.default
              localOverlay
            ];
          };
        };

        # Keep one canonical package-set extension for both the public overlay
        # and every platform module assembled into myCommon.
        defaultOverlay = lib.composeManyExtensions [
          inputs.nix-devtools.overlays.default
          unstableOverlay
          localOverlay
        ];

        # Pass the whole `inputs` so the module can reach `self`, which is only
        # available through the flake's own input closure.
        flakeModule = importApply ./modules inputs;
        # Repository-specific checks are intentionally outside the public modules.
        repositoryChecks = inputs.nix-devtools.lib.nixDevtools.flakeModulesFromDirectoryRecursive ./tests;
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "riscv64-linux"
        ];

        imports = [
          inputs.flake-parts.flakeModules.modules
          inputs.treefmt-nix.flakeModule
          inputs.nix-devtools.flakeModule

          flakeModule
        ]
        ++ repositoryChecks;

        # Public package-set API for consumers that want the overlay directly.
        flake.overlays.default = defaultOverlay;

        perSystem =
          {
            system,
            ...
          }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
              ];
            };
          in
          {
            _module.args.pkgs = pkgs;

            packages = { };

            devShells = {
              default = pkgs.mkShell {
                packages = [ ];
              };

              rust = pkgs.mkShell {
                env.PROMPT_NAME = "devshell/rust";
              };
            };

            treefmt = {
              projectRootFile = "flake.nix";

              programs = {
                nixfmt.enable = true;
                taplo.enable = true;
              };
            };

            gitHooks = {
              pre-commit = pkgs.writeNushellScript "pre-commit" ''
                print "⚡️ Running pre-commit checks..."
                nix build .#checks.${system}.treefmt -L
              '';

              pre-push = pkgs.writeNushellScript "pre-push" ''
                print "⚡️ Running pre-push checks..."
                nix flake check -L
              '';
            };
          };
      }
    );
}
