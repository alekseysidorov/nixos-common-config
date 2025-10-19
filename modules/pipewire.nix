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

    # Low latency timing configuration
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [ 44100 48000 ];
      "default.clock.quantum" = 32; # попробуешь 16, если тянет
      "default.clock.min-quantum" = 16;
      "default.clock.max-quantum" = 1024;
      "default.clock.force-quantum" = 32;
      "default.clock.force-rate" = 48000;
    };

    extraConfig.pipewire."context.rt" = {
      "rt.prio" = 95;
      "rt.time.soft" = 200000;
      "rt.time.hard" = 200000;
      "nice.level" = -15;
    };

    # Fine tuning for compa tibility with pulseudio applications
    extraConfig.pipewire-pulse."context.properties" = {
      "api.alsa.period-size" = 16;
      "api.alsa.headroom" = 0;
    };
  };
}
