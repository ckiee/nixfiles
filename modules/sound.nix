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
      rate = mkOption rec {
        type = types.int;
        default = 48000;
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
            "default.clock.rate" = rate;
            "default.clock.quantum" = quantum;
            "default.clock.min-quantum" = quantum;
            "default.clock.max-quantum" = quantum;
            "core.daemon" = true;
            "core.name" = "pipewire-0";
            "mem.warn-mlock" = true;
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
                "pulse.min.req" = "${toString quantum}/${toString rate}";
                "pulse.default.req" = "${toString quantum}/${toString rate}";
                "pulse.max.req" = "${toString quantum}/${toString rate}";
                "pulse.min.quantum" = "${toString quantum}/${toString rate}";
                "pulse.max.quantum" = "${toString quantum}/${toString rate}";
                "pulse.min.frag" = "${toString quantum}/${toString rate}";
                "pulse.default.frag" = "${toString rate}/${toString rate}";
                "pulse.default.tlength" = "${toString rate}/${toString rate}";
                "server.address" = [ "unix:native" "unix:/tmp/pulse-socket" ];
              };
            }
          ];

          "stream.properties" = {
            node.latency = "${toString quantum}/${toString rate}";
            resample.quality = 1;
          };
        };

        config.client = {
          "filter.properties" = {
            "node.latency" = "${toString quantum}/${toString rate}";
          };

          "stream.properties" = {
            "node.latency" = "${toString quantum}/${toString rate}";
            "resample.quality" = 1;
          };
        };

        config.client-rt = {
          "filter.properties" = {
            "node.latency" = "${toString quantum}/${toString rate}";
            "resample.quality" = 1;
          };

          "stream.properties" = {
            "node.latency" = "${toString quantum}/${toString rate}";
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
