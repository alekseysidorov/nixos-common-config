{ inputs, ... }:

let
  commandsModule =
    {
      flake-parts-lib,
      lib,
      ...
    }:

    {
      options.perSystem = flake-parts-lib.mkPerSystemOption (
        {
          config,
          pkgs,
          system,
          ...
        }:

        let
          cfg = config.myCommon.flake.commands;

          # Use this flake's canonical package universe locally. Consumers do
          # not need to install the overlay globally just to use the commands.
          pkgsLocal = pkgs.extend inputs.self.overlays.default;

          inherit (pkgsLocal.stdenv.hostPlatform) isDarwin isLinux;

          # `activate` is one semantic command. The platform-specific rebuild
          # implementation remains internal to the module.
          activationBackend =
            if isDarwin then
              {
                package = inputs.nix-darwin.packages.${system}.darwin-rebuild;
                command = "^sudo darwin-rebuild";
              }
            else if isLinux then
              {
                package = pkgsLocal.nixos-rebuild;
                command = "^nixos-rebuild --sudo";
              }
            else
              null;

          # Private implementation of the public `cleanup` app.
          cleanup = pkgsLocal.writeNushellApplication {
            name = "cleanup";

            runtimeInputs = [
              pkgsLocal.nix
            ];

            text = ''
              # Garbage-collect system and user store paths, then optimise the store.
              ^sudo nix store gc -vv
              ^nix store gc -vv
              ^nix store optimise
            '';
          };

          # Private implementation of the public `activate` app.
          activate =
            if activationBackend == null then
              null
            else
              pkgsLocal.writeNushellApplication {
                name = "activate";

                runtimeInputs = [
                  pkgsLocal.nix
                  activationBackend.package
                ];

                extraConfig = ''
                  alias rebuild = ${activationBackend.command}
                '';

                text = ''
                  # Activate this flake's system configuration.
                  def --wrapped main [...args: string] {
                    rebuild switch --flake ".#" ...$args
                  }
                '';
              };
        in
        {
          options.myCommon.flake.commands.enable = lib.mkEnableOption "common flake commands";

          config = lib.mkIf cfg.enable {
            # Apps are the public interface. Their backing derivations remain
            # private implementation details of this module.
            apps = {
              cleanup = {
                type = "app";
                program = lib.getExe cleanup;

                meta.description = "Collect obsolete Nix store paths and optimise the local Nix store.";
              };
            }
            // lib.optionalAttrs (activate != null) {
              activate = {
                type = "app";
                program = lib.getExe activate;

                meta.description = "Activate this flake's system configuration.";
              };
            };
          };
        }
      );

      # TODO: support Home Manager as an alternative activation backend.
      #
      # Intended API:
      #
      #   myCommon.flake.commands.activate.useHomeManager = true;
      #
      # The same `apps.activate` entrypoint should then invoke
      # `home-manager switch --flake ...` instead of nixos-rebuild or
      # darwin-rebuild. The remaining question is how to identify the Home
      # Manager configuration cleanly without restoring primaryUser.
    };
in
{
  imports = [
    commandsModule
  ];

  flake.modules.flake.myCommon.imports = [
    commandsModule
  ];
}
