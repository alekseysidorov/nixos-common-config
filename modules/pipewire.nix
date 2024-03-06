{ pkgs, ... }:

{
  hardware.pulseaudio.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = true;

    # See this article
    # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
    # wireplumber.configPackages = [
    #   (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
    #     		bluez_monitor.properties = {
    #     			["bluez5.enable-sbc-xq"] = true,
    #     			["bluez5.enable-msbc"] = true,
    #     			["bluez5.enable-hw-volume"] = true,
    #     			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    #     		}
    #     	'')
    # ];
  };
}
