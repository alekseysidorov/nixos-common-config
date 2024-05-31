{
  description = "Common parts of Nixos configuration";

  inputs = {
    # Default to unstable, but you may override it by using the 
    # `nixos-common-config.inputs.nixpkgs.follows = "your-own-nixpkgs"`
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        };
        # Eval the treefmt modules from ./treefmt.nix
        treefmtConfig = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };
        treefmt = (treefmt-nix.lib.evalModule pkgs treefmtConfig).config.build;
      in
      {
        # for `nix fmt`
        formatter = treefmt.wrapper;
        # for `nix flake check`
        checks.formatting = treefmt.check self;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.nixpkgs-fmt
          ];
        };

        # Additional subcommands to maintain home-manager setups.
        packages = {
          update = pkgs.writeShellScriptBin "update.sh"
            ''
              nix flake update
            '';

          # Activate system scripts like in flake-parts
          activate-home = pkgs.writeShellApplication {
            name = "activate-home";
            runtimeInputs = with pkgs; [ home-manager ];
            text = ''
              home-manager switch --flake . -L
              sudo -i nix upgrade-nix
            '';
          };

          activate-darwin = pkgs.writeShellScriptBin "activate.sh"
            ''
              darwin-rebuild switch --flake . -L
            '';

          activate-nixos = pkgs.writeShellScriptBin "activate.sh"
            ''
              nixos-rebuild switch --flake . -L --use-remote-sudo
            '';

          cleanup = pkgs.writeShellScriptBin "activate.sh"
            ''
              nix store gc -v
              nix store optimise
            '';
        };
      })
    # Add system independent modules.
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
      };

      # All home-manager configurations are kept here.
      homeModules = {
        common = import ./modules/home/common.nix;
        develop = import ./modules/home/develop.nix;
      };
    }
  ;
}
