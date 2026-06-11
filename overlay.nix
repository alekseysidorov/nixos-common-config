{ inputs, ... }:

final: prev:
let
  system = prev.stdenv.hostPlatform.system;
in
{
  # Unstable overlay providing newer versions of selected packages.
  unstable = import inputs.nixpkgs-unstable {
    localSystem = system;
    inherit (prev) config overlays;
  };
  # Additional packages from flake inputs.
  nufmt = inputs.nufmt.packages.${system}.nufmt;

  # Custom packages.

  cargo-fmt-toml = final.callPackage ./pkgs/cargo-fmt-toml.nix { };
  comchan = final.callPackage ./pkgs/comchan.nix { };
  vk-turn-proxy = final.callPackage ./pkgs/vk-turn-proxy.nix { };

  /*
    Creates a Nushell script application.

    Similar to [writeShellScriptBin][1] but targets `.nu` scripts instead of shell scripts.
    The script is loaded via `builtins.readFile`, so it must be passed as a path to the source file (not its content).

    [1]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/manual.xml

    # Arguments
    - `name` — name of the application and executable; becomes `$out/bin/<name>`
    - `script` — path to the `.nu` script file
    - `runtimeInputs` — additional packages added to the beginning of `PATH`; defaults to `[ ]`
    - `env` — Nix attribute set whose keys become exported environment variables (e.g. `{ VAR = "value"; }`)
    - `meta` — arbitrary attribute set merged into the result (typically `{ description; mainProgram; })`

    # Example
    ```nix
    writeNuApplication {
      name = "vpn-peer";
      script = ./tools/vpn-peer.nu;
      runtimeInputs = with pkgs; [ sops age ];
      env = { SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt"; };
      meta.mainProgram = "vpn-peer";
    }
    ```
  */
  writeNuApplication =
    {
      name,
      script,
      runtimeInputs ? [ ],
      env ? { },
      meta ? { },
    }:
    let
      runtimePath = final.lib.makeBinPath runtimeInputs;
      nuScript = final.writeText "${name}.nu" (builtins.readFile script);
      # Expose env vars as shell exports. Nu doesn't have a way to set env vars for scripts, so we have to do it ourselves.
      envExports = map (key: "export ${key}=${env.${key}}") (builtins.attrNames env);
    in
    final.writeShellScriptBin name ''
      export PATH="${runtimePath}:$PATH"
      ${builtins.concatStringsSep "\n" envExports}
      exec "${final.nushell}/bin/nu" "${nuScript}" "$@"
    ''
    // meta;
}
