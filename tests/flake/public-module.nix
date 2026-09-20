{ inputs, ... }:

{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:

    let
      # Model a downstream flake which only imports the public module. In
      # particular, it does not know about or provide the module's inputs.
      consumer = inputs.flake-parts.lib.mkFlake { inputs = { }; } {
        imports = [
          inputs.flake-parts.flakeModules.modules
          inputs.self.flakeModule
        ];

        systems = [ system ];

        perSystem = {
          _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
          myCommon.flake.commands.enable = true;
        };
      };

      apps = consumer.apps.${system};
    in
    {
      checks.test-public-flake-module-consumer =
        assert apps ? activate;
        assert apps ? cleanup;
        assert apps.activate.type == "app";
        assert apps.cleanup.type == "app";

        pkgs.runCommand "test-public-flake-module-consumer" { } ''
          touch $out
        '';
    };
}
