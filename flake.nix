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
      let
        # Repository-specific checks are intentionally outside the public modules.
        repositoryChecks = inputs.nix-devtools.lib.nixDevtools.flakeModulesFromDirectoryRecursive ./tests;
      in
      {
        imports = [
          inputs.flake-parts.flakeModules.modules
          inputs.treefmt-nix.flakeModule
          inputs.nix-devtools.flakeModule
          ./modules
        ]
        ++ repositoryChecks;

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "riscv64-linux"
        ];

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
