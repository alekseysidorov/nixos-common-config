{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
    in
    {
      # Keep activation explicit: entering a shell never changes the system.
      packages = {
        activate-home = pkgs.writeNuShellApplication {
          name = "activate-home";
          runtimeInputs = [ pkgs.home-manager ];
          text = ''
            def --wrapped main [...args: string] {
              ^home-manager switch --flake ".#" ...$args
            }
          '';
        };

        cleanup = pkgs.writeNuShellApplication {
          name = "cleanup";
          runtimeInputs = [ pkgs.nix ];
          text = ''
            ^sudo nix store gc -vv
            ^nix store gc -vv
            ^nix store optimise
          '';
        };
      }
      // lib.optionalAttrs (isDarwin || isLinux) {
        activate = pkgs.writeNuShellApplication {
          name = "activate";
          runtimeInputs = [
            pkgs.nix
          ]
          ++ (
            if isDarwin then [ inputs.nix-darwin.packages.${system}.darwin-rebuild ] else [ pkgs.nixos-rebuild ]
          );
          # Select the platform backend without duplicating argument forwarding.
          extraConfig =
            if isDarwin then
              ''
                alias rebuild = ^sudo darwin-rebuild
              ''
            else
              ''
                alias rebuild = ^nixos-rebuild --sudo
              '';
          text = ''
            def --wrapped main [...args: string] {
              rebuild switch --flake ".#" ...$args
            }
          '';
        };
      };
    };
}
