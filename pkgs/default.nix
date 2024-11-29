final: prev:

{
  criterion-table = prev.callPackage ./criterion-table.nix { };
    zed-editor = prev.buildFHSUserEnv {
    name = "zed";
    targetPkgs = prev:
      with prev; [
        zed-editor
      ];
    runScript = "zed";
  };
}
