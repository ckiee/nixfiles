{ pkgs, ... }: {

  security.rtkit.enable = true;
  hardware.pulseaudio.daemon.config = {
    "high-priority" = "yes";
    "nice-level" = "-15";
    "realtime-scheduling" = "yes";
    "realtime-priority" = "50";
    "resample-method" = "speex-float-0";
    "default-fragments" = "2";
    "default-fragment-size-msec" = "2";
  };
}
