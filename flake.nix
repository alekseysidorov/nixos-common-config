{
  description = "Common parts of Nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , flake-utils
    , treefmt-nix
    }: flake-utils.lib.eachDefaultSystem
      (system:
      let
        # Setup nixpkgs.
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./pkgs)
          ];
        };
        # Eval the treefmt modules from ./treefmt.nix
        treefmt = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
      in
      {
        # for `nix fmt`
        formatter = treefmt.wrapper;
        # for `nix flake check`
        checks.formatting = treefmt.check self;

        devShells = {
          default = with pkgs; mkShell {
            buildInputs = [
              nixpkgs-fmt
              criterion-table
              serial-monitor
              mod-host
              lilv
            ];
          };

          # Minimal shell for Rust development.
          rust = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              pkgconf
              openssl
              rustup
              systemd
              nushell
              python3
              rustPlatform.bindgenHook
            ];

            env.PROMPT_NAME = "devshell/rust";
          };
        };

        # Additional subcommands to maintain home-manager setups.
        packages = rec {
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = with pkgs; [ nix ];
            text = ''
              nix flake update
            '';
          };
          # Activate system scripts like in flake-parts
          activate-home = pkgs.writeShellApplication {
            name = "activate-home";
            runtimeInputs = with pkgs; [ home-manager ];
            text = ''
              home-manager --flake . -L switch
            '';
          };
          activate-darwin = pkgs.writeShellApplication {
            name = "activate-darwin";
            runtimeInputs = [ nix-darwin.packages.${system}.darwin-rebuild ];
            text = ''
              sudo darwin-rebuild switch --flake ".#''${1:-}"  -L
            '';
          };
          activate-nixos = pkgs.writeShellApplication {
            name = "activate-nixos";
            runtimeInputs = with pkgs; [ nixos-rebuild-ng ];
            text = ''
              nixos-rebuild-ng --flake .# -L switch --sudo
            '';
          };

          activate =
            if system == "aarch64-darwin"
            then activate-darwin
            else activate-nixos;
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
      })
    # System independent modules.
    // {
      # All nixOS modules are kept here
      nixosModules = {
        overlays = import ./modules/overlays.nix;
      };
      # All home-manager configurations are kept here.
      homeModules = {
        all = import ./modules/home;
        core = import ./modules/home/core.nix;
        develop = import ./modules/home/develop.nix;
        shell = import ./modules/home/shell.nix;
        git = import ./modules/home/git.nix;
      };
    }
  ;
}
