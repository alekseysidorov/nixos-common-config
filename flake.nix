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
      url = "github:alekseysidorov/rust-dev-flake/dev";
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
          # Use the common overlay in all per-system modules.
          _module.args.pkgs = pkgs;
          # Expose activation and maintenance commands through `nix run`.
          packages = {
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

          # Enter with `nix develop` or `nix develop .#rust`.
          devShells = {
            # Try tools provided by the common overlay.
            default = pkgs.mkShell {
              buildInputs = with pkgs; [
                unstable.comchan
                nufmt
              ];
            };
            # Supply native dependencies while rustup manages the Rust toolchain.
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

          # Share formatting rules between `nix fmt` and CI.
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rs;
              };
              taplo.enable = true;
            };
          };

          # Verify package builds and the sample Darwin configuration with `nix flake check`.
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
        };
    };
}
