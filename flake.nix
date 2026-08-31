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
    rust-dev-flake = {
      url = "path:/Users/wildboarder/Projects/nix/rust-dev-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nufmt = {
      url = "github:nushell/nufmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      flake-parts,
      ...
    }@inputs:
    let
      localOverlay = (import ./overlay.nix) { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Declared systems that your flake supports. These will be enumerated in perSystem
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      # Modules that are imported into the flake.
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.rust-dev-flake.flakeModules.gitHooks

        ./flake-modules
      ];

      perSystem =
        {
          system,
          lib,
          ...
        }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              localOverlay
            ];
          };

          mkDarwinCheck =
            module:
            lib.mkIf (lib.hasSuffix "-darwin" system) ((import module { inherit self inputs system; }).system);
        in
        {
          # Set up nixpkgs with the local overlay and any additional overlays you need.
          _module.args.pkgs = pkgs;
          # Setup nix formatting with treefmt-nix.
          treefmt = {
            # Project root marker used by treefmt
            projectRootFile = "flake.nix";
            programs = {
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rs;
              };
              taplo.enable = true;
            };
          };

          checks = {
            comchan = pkgs.comchan;
            darwin-default = (mkDarwinCheck ./checks/darwin-default.nix);
          };

          # Install explicitly with `nix run .#install-git-hooks`.
          gitHooks = {
            pre-commit = pkgs.writeShellScript "pre-commit" ''
              set -euo pipefail
              echo "⚡️ Running pre-commit checks..."
              nix build .#checks.${system}.treefmt -L
            '';
            pre-push = pkgs.writeShellScript "pre-push" ''
              set -euo pipefail
              echo "⚡️ Running pre-push checks..."
              nix flake check -L
            '';
          };

          # Development shell with common tools for Rust and Nix development.
          devShells = {
            # Default shell with all tools in pkgs directory to test them out.
            default = pkgs.mkShell {
              buildInputs = with pkgs; [
                unstable.comchan
                nufmt
              ];
            };
            # Minimal shell for Rust development.
            rust =
              with pkgs;
              mkShell {
                nativeBuildInputs = [
                  pkgconf
                  openssl
                  rustup
                  nushell
                  python3
                  rustPlatform.bindgenHook
                  comchan
                  rumdl
                ]
                ++ lib.optionals stdenv.hostPlatform.isLinux [ systemd ];

                env.PROMPT_NAME = "devshell/rust";
              };
          };

          packages = {
            # Activate system scripts, similar to flake-parts
            activate-home = pkgs.writeShellApplication {
              name = "activate-home";
              runtimeInputs = with pkgs; [ home-manager ];
              text = ''
                home-manager switch --flake .# "$@"
              '';
            };

            activate =
              let
                activate-darwin = pkgs.writeShellApplication {
                  name = "activate-darwin";
                  runtimeInputs = [
                    pkgs.nix
                    nix-darwin.packages.${system}.darwin-rebuild
                  ];
                  text = ''
                    sudo darwin-rebuild switch --flake .# "$@"
                  '';
                };
                activate-nixos = pkgs.writeShellApplication {
                  name = "activate-nixos";
                  text = ''
                    nixos-rebuild switch --flake .# --sudo "$@"
                  '';
                };
              in
              if system == "aarch64-darwin" then activate-darwin else activate-nixos;

            cleanup = pkgs.writeShellApplication {
              name = "cleanup";
              runtimeInputs = with pkgs; [ nix ];
              text = ''
                sudo nix store gc -vv
                nix store gc -vv
                nix store optimise
              '';
            };
          };
        };
    };
}
