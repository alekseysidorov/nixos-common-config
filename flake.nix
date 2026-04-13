{
  description = "Common parts of NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Set up nixpkgs.
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./pkgs)
          ];
        };
        # Evaluate the treefmt modules from ./treefmt.nix
        treefmt = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
      in
      {
        # For `nix fmt`
        formatter = treefmt.wrapper;
        # For `nix flake check`
        checks.formatting = treefmt.check self;

        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              comchan
            ];
          };

          # Minimal shell for Rust development.
          rust = pkgs.mkShell {
            nativeBuildInputs =
              with pkgs;
              [
                pkgconf
                openssl
                rustup
                nushell
                python3
                rustPlatform.bindgenHook
                comchan
                rumdl
              ]
              ++ lib.optionals stdenv.isLinux [ systemd ];

            env.PROMPT_NAME = "devshell/rust";
          };
        };

        # Additional subcommands for managing home-manager setups.
        packages = rec {
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = with pkgs; [ nix ];
            text = ''
              nix flake update
            '';
          };
          # Activate system scripts, similar to flake-parts
          activate-home = pkgs.writeShellApplication {
            name = "activate-home";
            runtimeInputs = with pkgs; [ home-manager ];
            text = ''
              home-manager --flake . -L switch
            '';
          };
          activate-darwin = pkgs.writeShellApplication {
            name = "activate-darwin";
            runtimeInputs = [
              pkgs.nix
              nix-darwin.packages.${system}.darwin-rebuild
            ];
            text = ''
              sudo darwin-rebuild switch --flake ".#''${1:-}"  -L
            '';
          };
          activate-nixos = pkgs.writeShellApplication {
            name = "activate-nixos";
            text = ''
              nixos-rebuild --flake .# -L switch --sudo
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
      }
    )
    # System-independent modules.
    // {
      # All NixOS modules are defined here
      nixosModules = {
        overlays = import ./modules/overlays.nix;
      };
      # All home-manager configurations are defined here.
      homeModules = {
        all = import ./modules/home;
        core = import ./modules/home/core.nix;
        develop = import ./modules/home/develop.nix;
        shell = import ./modules/home/shell.nix;
        git = import ./modules/home/git.nix;
      };
      # All nix-darwin modules are defined here
      darwinModules = {
        all = import ./modules/darwin;
        ollama = import ./modules/darwin/ollama.nix;
      };
    };
}
