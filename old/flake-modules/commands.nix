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

      rebuild =
        if isDarwin then
          {
            package = inputs.nix-darwin.packages.${system}.darwin-rebuild;
            command = "^sudo darwin-rebuild";
          }
        else
          {
            package = pkgs.nixos-rebuild;
            command = "^nixos-rebuild --sudo";
          };
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
            rebuild.package
          ];
          extraConfig = "alias rebuild = ${rebuild.command}";
          text = ''
            def --wrapped main [...args: string] {
              rebuild switch --flake ".#" ...$args
            }
          '';
        };
      };
    };
}
