{ config, pkgs, lib, ... }:

let cfg = config.cookie.sound;
  sources = import ../../nix/sources.nix;
in with lib; {
  imports = [ "${sources.musnix}" ];
  options.cookie.sound = {
    enable = mkEnableOption "Enable the ALSA sound system";
    pro = mkEnableOption "Enable additional Pro Audio configuration";
    pulse = {
      enable = mkEnableOption "Enable the PulseAudio sound system";
      lowLatency =
        mkEnableOption "Enable the low-latency PulseAudio configuration";
    };
    pipewire = {
      enable = mkEnableOption "Enable the PipeWire sound system";
      quantum = mkOption rec {
        type = types.int;
        default = 256;
        description =
          "Magical PipeWire value to magically perform things faster";
        example = default;
      };
      rate = mkOption rec {
        type = types.int;
        default = 44100;
        description = "The sample rate";
        example = default;
      };

    };
  };

  config = mkMerge [
    {
      assertions = [{
        assertion = !(cfg.pulse.enable && cfg.pipewire.enable);
        message = "PulseAudio conflicts with PipeWire";
      }];
    }
    ### ALSA
    # - The option definition `sound' in `/home/ckie/git/nixfiles/modules/sound' no longer has any effect; please remove it.
    #  The option was heavily overloaded and can be removed from most configurations.
    # (mkIf cfg.enable { sound.enable = true; })
    ### Musnix
    (mkIf cfg.pro {
      musnix.enable = true;
      cookie.user.extraGroups = [ "audio" ];
    })
    ### PulseAudio
    (mkIf cfg.pulse.enable {
      security.rtkit.enable = true;
      hardware.pulseaudio = mkMerge [
        (mkIf cfg.pulse.lowLatency {
          configFile = ./default.pa;
          daemon.config = {
            "high-priority" = "yes";
            "nice-level" = "-15";
            "realtime-scheduling" = "yes";
            "realtime-priority" = "50";
            "resample-method" = "speex-float-0";
            "default-fragments" = "2";
            "default-fragment-size-msec" = "4";

            "default-sample-format" = "s32le";
            "default-sample-rate" = toString rate;
            "alternate-sample-rate" = toString rate;
            "default-sample-channels" = "2";
          };
        })
        { enable = true; }
      ];
    })
    ### PipeWire
    (mkIf cfg.pipewire.enable (let inherit (cfg.pipewire) quantum rate;
    in {
      environment.systemPackages = with pkgs; [ helvum easyeffects pulseaudio alsa-utils ];

      # gnome desktop enables pulse with mkDefault, explicitly turn it off:
      hardware.pulseaudio.enable = false;

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        # used to have lots of config from sctanf, last in a5626226295a08b9c648f8f75594a65a57095f70
      };
    }))
  ];
}
