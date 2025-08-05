{
  description = "Common parts of Nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
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
          default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.nixpkgs-fmt
              # check packages
              pkgs.criterion-table
              pkgs.serial-monitor
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
            ];

            env.PROMPT_NAME = "devshell/rust";
          };
        };

        # Additional subcommands to maintain home-manager setups.
        packages = {
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
            runtimeInputs = [ ];
            text = ''
              darwin-rebuild --flake . -L switch
            '';
          };
          activate-nixos = pkgs.writeShellApplication {
            name = "activate-nixos";
            runtimeInputs = with pkgs; [ nixos-rebuild-ng ];
            text = ''
              nixos-rebuild-ng --flake .# -L switch --sudo
            '';
          };
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
      overlays.default = import ./overlay.nix {
        nixpkgs-unstable = nixpkgs-unstable;
        config.allowUnfree = true;
      };

      # All nixOS modules are kept here
      nixosModules = {
        common = import ./modules/common.nix;
        linux = import ./modules/linux.nix;
        darwin = import ./modules/darwin.nix;
        pipewire = import ./modules/pipewire.nix;
        overlays = import ./modules/overlays.nix;
      };

      # All home-manager configurations are kept here.
      homeModules = {
        common = import ./modules/home/common.nix;
        develop = import ./modules/home/develop.nix;
      };
    }
  ;
}
