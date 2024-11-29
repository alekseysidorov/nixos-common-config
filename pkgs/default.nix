final: prev:

{
  criterion-table = prev.callPackage ./criterion-table.nix { };

  zed-editor-fhs = prev.buildFHSUserEnv {
    name = "zed";
    targetPkgs = prev:
      with prev; [
        zed-editor
      ];
    runScript = "zed";
  };
}
