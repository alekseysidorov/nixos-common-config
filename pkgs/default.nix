final: prev:
{
  criterion-table = final.callPackage ./criterion-table.nix { };
  serial-monitor = final.callPackage ./serial-monitor.nix { };
  serial-console = final.callPackage ./serial-console.nix { };

}
