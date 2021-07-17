{ config, pkgs, lib, ... }:

let cfg = config.cookie.sound;
in with lib; {
  options.cookie.sound = {
    enable = mkEnableOption "Enable the ALSA sound system";
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
    (mkIf cfg.enable { sound.enable = true; })
    ### PulseAudio
    (mkIf cfg.pulse.enable {
      security.rtkit.enable = true;
      hardware.pulseaudio = mkMerge [
        (mkIf cfg.pulse.lowLatency {
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
    })
    ### PipeWire
    (mkIf cfg.pipewire.enable (let quantum = cfg.pipewire.quantum;
    in {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        jack.enable = true;
        config.pipewire = {
          "context.properties" = {
            "link.max-buffers" = 16;
            "log.level" = 2;
            "default.clock.rate" = 96000;
            "default.clock.quantum" = quantum;
            "default.clock.min-quantum" = quantum;
            "default.clock.max-quantum" = quantum;
            "core.daemon" = true;
            "core.name" = "pipewire-0";
          };
          "context.modules" = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
              flags = [ "ifexists" "nofail" ];
            }

            { name = "libpipewire-module-protocol-native"; }

            { name = "libpipewire-module-profiler"; }

            { name = "libpipewire-module-metadata"; }

            { name = "libpipewire-module-spa-device-factory"; }

            { name = "libpipewire-module-spa-node-factory"; }

            { name = "libpipewire-module-client-node"; }

            { name = "libpipewire-module-client-device"; }

            {
              name = "libpipewire-module-portal";
              flags = [ "ifexists" "nofail" ];
            }

            {
              name = "libpipewire-module-access";
              args = { };
            }

            { name = "libpipewire-module-adapter"; }

            { name = "libpipewire-module-link-factory"; }

            { name = "libpipewire-module-session-manager"; }
          ];
        };

        config.pipewire-pulse = {
          "context.properties" = { "log.level" = 2; };
          "context.modules" = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
              flags = [ "ifexists" "nofail" ];
            }

            { name = "libpipewire-module-protocol-native"; }

            { name = "libpipewire-module-client-node"; }

            { name = "libpipewire-module-adapter"; }

            { name = "libpipewire-module-metadata"; }

            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                "pulse.min.req" = "${toString quantum}/96000";
                "pulse.default.req" = "${toString quantum}/96000";
                "pulse.max.req" = "${toString quantum}/96000";
                "pulse.min.quantum" = "${toString quantum}/96000";
                "pulse.max.quantum" = "${toString quantum}/96000";
                "pulse.min.frag" = "${toString quantum}/96000";
                "pulse.default.frag" = "96000/96000";
                "pulse.default.tlength" = "96000/96000";
                "server.address" = [ "unix:native" "unix:/tmp/pulse-socket" ];
              };
            }
          ];

          "stream.properties" = {
            node.latency = "${toString quantum}/96000";
            resample.quality = 1;
          };
        };

        config.client = {
          "filter.properties" = {
            "node.latency" = "${toString quantum}/96000";
          };

          "stream.properties" = {
            "node.latency" = "${toString quantum}/96000";
            "resample.quality" = 1;
          };
        };

        config.client-rt = {
          "filter.properties" = {
            "node.latency" = "${toString quantum}/96000";
            "resample.quality" = 1;
          };

          "stream.properties" = {
            "node.latency" = "${toString quantum}/96000";
          };
        };

        media-session = {
          config.alsa-monitor = {
            "rules" = [{
              matches = [{ device.name = "~alsa_card.*"; }];
              actions = {
                update-props = {
                  api.alsa.use-acp = true;
                  api.alsa.soft-mixer = false;
                  api.acp.auto-profile = false;
                  api.acp.auto-port = false;
                  api.alsa.disable-batch = true;
                };
              };
            }
            # {
            #   matches = [{
            #     node.name =
            #       "alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K5_Pro-00.*";
            #   }];
            #   actions = {
            #     update-props = {
            #       node.nick = "FiiO K5 Pro";
            #       node.pause-on-idle = false;
            #       resample.quality = 1;
            #       channelmix.normalize = false;
            #       audio.channels = 2;
            #       audio.format = "S32LE";
            #       audio.rate = 96000;
            #       audio.position = "FL,FR";
            #       api.alsa.period-size = ${toString quantum};
            #     };
            #   };
            # }
              ];
          };
          config.media-session = {
            "context.modules" = [
              {
                name = "libpipewire-module-rtkit";
                args = {
                  "nice.level" = -11;
                  "rt.prio" = 88;
                  "rt.time.soft" = 200000;
                  "rt.time.hard" = 200000;
                };
                flags = [ "ifexists" "nofail" ];
              }

              { name = "libpipewire-module-protocol-native"; }

              { name = "libpipewire-module-client-node"; }

              { name = "libpipewire-module-client-device"; }

              { name = "libpipewire-module-adapter"; }

              { name = "libpipewire-module-metadata"; }

              { name = "libpipewire-module-session-manager"; }
            ];
          };
        };
      };
    }))
  ];
}
