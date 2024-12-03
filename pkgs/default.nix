final: prev:

let
  isLinux = prev.stdenv.targetPlatform.isLinux;
in
{
  criterion-table = prev.callPackage ./criterion-table.nix { };
  # Special case for Zed on linux
  zed-editor =
    if isLinux then
      prev.zed-editor.fhsWithPackages
        (pkgs:
          with pkgs; [ zlib openssl ]
        )
    else prev.zed-editor;
}
