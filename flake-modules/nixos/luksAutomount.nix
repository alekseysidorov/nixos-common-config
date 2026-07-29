{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkIf
    mkOption
    mapAttrs'
    mapAttrsToList
    removePrefix
    ;

  # Generates the systemd .mount unit name from a mount point
  # (e.g. /mnt/ssd → mnt-ssd.mount)
  mkMountServiceName =
    mountPoint: builtins.replaceStrings [ "/" ] [ "-" ] (removePrefix "/" mountPoint) + ".mount";

  # For udev hotplug: creates a udev rules package for a disk.
  # This triggers cryptsetup and mount via systemd when the device appears.
  mkUdevRulesPackage =
    filename: rulesText:
    pkgs.stdenv.mkDerivation {
      name = "${filename}-udev-rules";
      src = pkgs.writeText "${filename}.rules" rulesText;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/lib/udev/rules.d
        cp $src $out/lib/udev/rules.d/${filename}.rules
      '';
    };

  # For fileSystems: builds an attrset keyed by mountPoint for NixOS fileSystems option.
  mkFileSystems = mapAttrs' (
    luksName: disk: {
      name = disk.mountPoint;
      value = {
        device = "/dev/mapper/${luksName}";
        fsType = disk.fsType;
        options = disk.options ++ [
          "nofail"
          "noauto"
          "x-systemd.requires=${disk.cryptsetupServiceName}"
          "x-systemd.automount"
        ];
      };
    }
  );

  # For systemd-cryptsetup
  mkSystemdCryptsetup = mapAttrs' (
    luksName: disk:
    let
      cryptsetupBin = "${pkgs.systemd}/lib/systemd/systemd-cryptsetup";
    in
    {
      name = "systemd-cryptsetup@${luksName}";
      value = {
        description = "Unlock LUKS disk ${luksName}";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${cryptsetupBin} attach ${luksName} /dev/disk/by-uuid/${disk.luksUuid} none luks";
          ExecStop = "${cryptsetupBin} detach ${luksName}";
        };
      };
    }
  );

  # For udev integration: returns a list of udev rule packages for all disks.
  mkUdevPackages = mapAttrsToList (
    luksName: disk:
    mkUdevRulesPackage "99-luks-automount-${luksName}" ''
      ACTION=="add", \
      ENV{ID_FS_UUID}=="${disk.luksUuid}", \
      TAG+="systemd", \
      ENV{SYSTEMD_WANTS}="${disk.cryptsetupServiceName} ${disk.mountServiceName}"
    ''
  );
in
{
  options.services.luksAutomount = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable LUKS automount service for one or more encrypted disks.
      '';
    };

    disks = mkOption {
      description = ''
        Attribute set of LUKS disks to automount. Each key is a unique disk/service name.
      '';
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              luksUuid = mkOption {
                type = types.str;
                example = "8890d7cf-a6d4-4410-930a-7ce725c6e3dc";
                description = "UUID of the LUKS partition.";
              };

              mountPoint = mkOption {
                type = types.str;
                example = "/mnt/ssd";
                description = "Mount point for the unlocked filesystem.";
              };

              fsType = mkOption {
                type = types.str;
                example = "ext4";
                description = "Filesystem type inside the LUKS container (e.g., ext4, btrfs).";
              };

              options = mkOption {
                type = types.listOf types.str;
                default = [ ];
                example = [
                  "noatime"
                  "nodiratime"
                ];
                description = ''
                  Filesystem mount options.
                  The "nofail" option is added automatically so the system can boot even if the disk is absent;
                  adding it explicitly here is redundant but harmless.
                '';
              };

              mountServiceName = mkOption {
                type = types.str;
                readOnly = true;
                apply = _: mkMountServiceName config.mountPoint;
                description = "Systemd mount unit name for this disk (auto-generated from mountPoint).";
              };

              cryptsetupServiceName = mkOption {
                type = types.str;
                readOnly = true;
                apply = _: "systemd-cryptsetup@${name}.service";
                description = "systemd cryptsetup unit name for this disk (auto-generated from the disk attribute key).";
              };
            };
          }
        )
      );

      example = {
        ssdcrypt = {
          luksUuid = "8890d7cf-a6d4-4410-930a-7ce725c6e3dc";
          mountPoint = "/mnt/ssd";
          fsType = "ext4";
          options = [
            "noatime"
            "nodiratime"
          ];
        };
      };
    };
  };

  config = mkIf config.services.luksAutomount.enable {
    fileSystems = mkFileSystems config.services.luksAutomount.disks;
    systemd.services = mkSystemdCryptsetup config.services.luksAutomount.disks;
    services.udev.packages = mkUdevPackages config.services.luksAutomount.disks;
  };
}
