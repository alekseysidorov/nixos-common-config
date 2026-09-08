{ ... }:

let
  commandsModule =
    {
      config,
      inputs,
      lib,
      pkgs,
      system,
      ...
    }:

    let
      cfg = config.myCommon.flake.commands;

      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

      # Activation is one semantic command with a platform-specific backend.
      #
      # Keep the backend selection internal: callers should invoke `activate`
      # without knowing whether the current system is managed by NixOS or
      # nix-darwin.
      activationBackend =
        if isDarwin then
          {
            package = inputs.nix-darwin.packages.${system}.darwin-rebuild;
            command = "^sudo darwin-rebuild";
          }
        else if isLinux then
          {
            package = pkgs.nixos-rebuild;
            command = "^nixos-rebuild --sudo";
          }
        else
          null;

      # `cleanup` is a flake command, not part of the reusable package-set API.
      # Build it locally and expose only the executable entrypoint through
      # `apps.cleanup`.
      cleanup = pkgs.writeNushellApplication {
        name = "cleanup";

        runtimeInputs = [
          pkgs.nix
        ];

        text = ''
          ^sudo nix store gc -vv
          ^nix store gc -vv
          ^nix store optimise
        '';
      };

      # Build one `activate` command independent of the concrete system backend.
      # The selected rebuild tool is injected only as a runtime dependency.
      activate =
        if activationBackend == null then
          null
        else
          pkgs.writeNushellApplication {
            name = "activate";

            runtimeInputs = [
              pkgs.nix
              activationBackend.package
            ];

            extraConfig = ''
              alias rebuild = ${activationBackend.command}
            '';

            text = ''
              # Activate this flake's system configuration using the selected backend.
              def --wrapped main [...args: string] {
                rebuild switch --flake ".#" ...$args
              }
            '';
          };
    in
    {
      options.myCommon.flake.commands.enable = lib.mkEnableOption "common flake commands";

      config = lib.mkIf cfg.enable {
        # Apps are the public command surface.
        #
        # The underlying derivations intentionally remain private to this
        # module: they are implementation details rather than reusable
        # `pkgs.*` capabilities.
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

      # TODO: support Home Manager as an activation backend.
      #
      # The intended public API is:
      #
      #   myCommon.flake.commands.activate.useHomeManager = true;
      #
      # When enabled, the same `apps.activate` entrypoint should use
      # `home-manager switch --flake ...` instead of the platform system
      # backend. Keep `activate` as the single semantic command; selecting
      # NixOS, nix-darwin, or Home Manager is an implementation detail.
      #
      # The remaining design question is how to determine the Home Manager
      # flake target/configuration name without reintroducing a global
      # `primaryUser` abstraction. Add the option only once that target can
      # be derived or represented explicitly and cleanly.
    };
in
{
  perSystem = commandsModule;

  flake.modules.flake.myCommon.imports = [ commandsModule ];
}
