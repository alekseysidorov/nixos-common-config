{
  description = "Common parts of Nixos configuration";

  inputs = {
    # Default to unstable, but you may override it by using the 
    # `nixos-common-config.inputs.nixpkgs.follows = "your-own-nixpkgs"`
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.nixpkgs-fmt ];
        };

        formatter = config.treefmt.build.wrapper;
      };

      flake = {
        # All home-manager configurations are kept here.
        homeModules = {
          common = import ./modules/home/common.nix;
        };

        # All nixOS modules are kept here
        nixosModules = {
          common = import ./modules/common.nix;
          linux = import ./modules/linux.nix;
          darwin = import ./modules/darwin.nix;
          pipewire = import ./modules/pipewire.nix;
        };
      };
    };
}
