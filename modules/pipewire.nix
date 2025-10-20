{ ... }:

{
  # Tune real-time scheduling for low-latency audio.
  boot.kernel.sysctl."kernel.sched_rt_runtime_us" = -1;

  services.pulseaudio.enable = false;
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

    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 32;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 32;
      };

      "context.rt" = {
        "rt.prio" = 95;
        "rt.time.soft" = 200000;
        "rt.time.hard" = 200000;
        "nice.level" = -15;
      };
    };
  };
}
