{
  inputs,
  self,
  ...
}:

{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      testPkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };

      testApp = testPkgs.writeNuShellApplication {
        name = "overlay-smoke-test";

        runtimeInputs = [
          testPkgs.unstable.comchan
        ];

        text = ''
          comchan | ignore
        '';
      };
    in
    {
      checks.overlay =
        pkgs.runCommand "overlay-check"
          {
            nativeBuildInputs = [ testApp ];
          }
          ''
            overlay-smoke-test
            touch $out
          '';
    };
}
