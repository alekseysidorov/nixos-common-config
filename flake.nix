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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-dev-flake = {
      url = "github:alekseysidorov/rust-dev-flake";
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
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.rust-dev-flake.flakeModules.gitHooks

        ./modules
      ];

      # Declared systems that your flake supports. These will be enumerated in perSystem
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "riscv64-linux"
      ];

      perSystem =
        {
          config,
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
          # Use the common overlay in all per-system modules.
          _module.args.pkgs = pkgs;

          # Expose build artifacts and project commands through `nix build` / `nix run`.
          packages = {
          };

          # Enter with `nix develop` or `nix develop .#rust`.
          devShells = {
            # Try tools provided by the common overlay.
            default = pkgs.mkShell {
              packages = [ ];
            };

            # Supply native dependencies while rustup manages the Rust toolchain.
            rust = pkgs.mkShell {
              env.PROMPT_NAME = "devshell/rust";
            };
          };

          # Share formatting rules between `nix fmt` and CI.
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              taplo.enable = true;
            };
          };

          # Verify package builds and the sample Darwin configuration with `nix flake check`.
          checks = config.packages;

          # Install explicitly with `nix run .#install-git-hooks`.
          gitHooks = {
            pre-commit = pkgs.writeNuShellScript "pre-commit" ''
              print "⚡️ Running pre-commit checks..."
              nix build .#checks.${system}.treefmt -L
            '';
            pre-push = pkgs.writeNuShellScript "pre-push" ''
              print "⚡️ Running pre-push checks..."
              nix flake check -L
            '';
          };
        };
    };
}
