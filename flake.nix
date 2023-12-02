{
  description = "Description for the project";

  inputs = {
    # Default to unstable, but you may override it by using the 
    # `nixos-common-config.inputs.nixpkgs.follows = "your-own-nixpkgs"`
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flake = {
        # All home-manager configurations are kept here.
        homeModules = {
          common = import ./modules/home/common.nix;
        };
      };

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
    };
}
