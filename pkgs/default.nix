final: prev:
{
  criterion-table = final.callPackage ./criterion-table.nix { };
  serial-monitor = final.callPackage ./serial-monitor.nix { };
}
