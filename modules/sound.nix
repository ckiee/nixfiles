{ config, pkgs, lib, ... }:

let cfg = config.cookie.sound;
in with lib; {
  options.cookie.sound = {
    enable = mkEnableOption "Enable the sound system";
    lowLatency =
      mkEnableOption "Enable the low-latency PulseAudio configuration";
  };

  config = (mkIf cfg.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.daemon.config = mkIf cfg.lowLatency {
      "high-priority" = "yes";
      "nice-level" = "-15";
      "realtime-scheduling" = "yes";
      "realtime-priority" = "50";
      "resample-method" = "speex-float-0";
      "default-fragments" = "2";
      "default-fragment-size-msec" = "2";
    };
  });
}
