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
    security.rtkit.enable = mkDefault true;
    hardware.pulseaudio = mkMerge [
      (mkIf cfg.lowLatency {
        configFile = ../ext/default.pa;
        daemon.config = {
          "high-priority" = "yes";
          "nice-level" = "-15";
          "realtime-scheduling" = "yes";
          "realtime-priority" = "50";
          "resample-method" = "speex-float-0";
          "default-fragments" = "2";
          "default-fragment-size-msec" = "4";

          "default-sample-format" = "s32le";
          "default-sample-rate" = "48000";
          "alternate-sample-rate" = "48000";
          "default-sample-channels" = "2";
        };
      })
      { enable = true; }
    ];
  });
}
