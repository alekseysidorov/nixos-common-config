{ pkgs, ... }:
let
  broadwayPort = 8000;
  broadwayDisplay = ":5";

  gtk3 = pkgs.gtk3;
  guitarix = pkgs.guitarix;
in
{
  environment.systemPackages = [
    guitarix
  ];

  networking.firewall.allowedTCPPorts = [ broadwayPort ];

  systemd.user.services = {
    broadway = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      description = "GTK broadway backend";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${gtk3}/bin/broadwayd -a 0.0.0.0 -p ${builtins.toString broadwayPort} ${broadwayDisplay}'';
      };
    };

    guitarix-webui = {
      enable = true;
      requires = [ "broadway.service" "wireplumber.service" ];
      wantedBy = [ "default.target" ];
      description = "Guitarix web interface";

      environment = {
        GDK_BACKEND = "broadway";
        BROADWAY_DISPLAY = "${broadwayDisplay}";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${guitarix}/bin/guitarix'';
      };
    };
  };
}
