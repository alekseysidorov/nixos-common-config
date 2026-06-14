{
  description = "Common parts of NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modular flake framework.
    flake-parts.url = "github:hercules-ci/flake-parts";

    nufmt = {
      url = "github:nushell/nufmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
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
      localOverlay = ((import ./overlay.nix) self);
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Declared systems that your flake supports. These will be enumerated in perSystem
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        ./flake-modules/overlays.nix
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
              localOverlay
            ];
          };
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

          # Development shell with common tools for Rust and Nix development.
          devShells = {
            # Default shell with all tools in pkgs directory to test them out.
            default = pkgs.mkShell {
              buildInputs = with pkgs; [
                comchan
                cargo-fmt-toml
                vk-turn-proxy
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
                  cargo-fmt-toml
                ]
                ++ lib.optionals stdenv.isLinux [ systemd ];

                env.PROMPT_NAME = "devshell/rust";
              };
          };

          # deprecated: Additional subcommands for managing home-manager setups.
          packages = rec {
            # Activate system scripts, similar to flake-parts

            activate-home = pkgs.writeShellApplication {
              name = "activate-home";
              runtimeInputs = with pkgs; [ home-manager ];
              text = ''
                home-manager switch --flake .# "$@"
              '';
            };
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
            activate = if system == "aarch64-darwin" then activate-darwin else activate-nixos;

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

      flake = {
        # All home-manager configurations are defined here.
        homeManagerModules = {
          all = import ./modules/home;
          core = import ./modules/home/core.nix;
          develop = import ./modules/home/develop.nix;
          shell = import ./modules/home/shell.nix;
          git = import ./modules/home/git.nix;
        };
      };
    };
}
