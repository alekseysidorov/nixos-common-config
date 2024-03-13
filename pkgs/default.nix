final: prev:

{
  criterion-table = prev.callPackage ./criterion-table.nix { };
  cargo-makedocs = prev.callPackage ./cargo-makedocs.nix { };
  fdb71 = prev.callPackage ./foundationdb { };
}
