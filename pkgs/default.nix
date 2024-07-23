final: prev:

{
  criterion-table = prev.callPackage ./criterion-table.nix { };
  cargo-makedocs = prev.callPackage ./cargo-makedocs.nix { };
  zed-editor = prev.callPackage ./zed-editor {};
}
