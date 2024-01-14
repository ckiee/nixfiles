{ config, lib, pkgs, ... }:

let cfg = config.cookie.hardware;
in with lib; {
  options.cookie.hardware = {
    t480s = {
      enable = mkEnableOption "Enables Thinkpad T480s specific hardware quirks";
      undervolt = mkEnableOption "Enables Thinkpad T480s CPU undervolting";
    };

    motherboard = mkOption {
      type = types.nullOr (types.enum [ "amd" "intel" ]);
      default = null;
      description =
        lib.mdDoc "CPU family of motherboard. Used for `cookie.openrgb`";
    };
  };

  # We need to do this after the libinput Xorg config
  config = mkMerge [
    (mkIf cfg.t480s.enable {
      services.xserver.config = (mkAfter ''
        Section "InputClass"
          Identifier "Set NatrualScrolling for TrackPoint"
          Driver "libinput"
          MatchIsPointer "on"
          Option "NaturalScrolling" "off"
        EndSection

        Section "InputClass"
          Identifier "Set Tapping for Touchpad"
          Driver "libinput"
          MatchIsTouchpad "on"
          Option "Tapping" "off"
        EndSection
      '');

      # services.logind.extraConfig = ''
      #   HandlePowerKey=ignore
      # '';
    })

    (mkIf cfg.t480s.undervolt {
      services.throttled = {
        enable = true;

        extraConfig = ''
          [GENERAL]
          # Enable or disable the script execution
          Enabled: True
          # SYSFS path for checking if the system is running on AC power
          Sysfs_Power_Path: /sys/class/power_supply/AC*/online
          # Auto reload config on changes
          Autoreload: True

          ## Settings to apply while connected to Battery power
          [BATTERY]
          # Update the registers every this many seconds
          Update_Rate_s: 30
          # Max package power for time window #1
          PL1_Tdp_W: 29
          # Time window #1 duration
          PL1_Duration_s: 28
          # Max package power for time window #2
          PL2_Tdp_W: 44
          # Time window #2 duration
          PL2_Duration_S: 0.002
          # Max allowed temperature before throttling
          Trip_Temp_C: 85
          # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
          cTDP: 1
          # Disable BDPROCHOT (EXPERIMENTAL)
          Disable_BDPROCHOT: False

          ## Settings to apply while connected to AC power
          [AC]
          # Update the registers every this many seconds
          Update_Rate_s: 5
          # Max package power for time window #1
          PL1_Tdp_W: 44
          # Time window #1 duration
          PL1_Duration_s: 28
          # Max package power for time window #2
          PL2_Tdp_W: 44
          # Time window #2 duration
          PL2_Duration_S: 0.002
          # Max allowed temperature before throttling
          Trip_Temp_C: 95
          # Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
          # Uncomment only if you really want to use it
          # HWP_Mode: False
          # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
          cTDP: 2
          # Disable BDPROCHOT (EXPERIMENTAL)
          Disable_BDPROCHOT: False

          # All voltage values are expressed in mV and *MUST* be negative (i.e. undervolt)!
          # XXX: Tuned for thonkcookie
          [UNDERVOLT.BATTERY]
          # CPU core/cache voltage offset (mV)
          # On Skylake and newer CPUs CORE and CACHE values should match!
          # XXX: crashes between 160-170
          CORE: -150
          CACHE: -150
          # Integrated GPU voltage offset (mV)
          GPU: -80
          # System Agent voltage offset (mV)
          UNCORE: -80
          # Analog I/O voltage offset (mV)
          ANALOGIO: 0

          # [ICCMAX.AC]
          # # CPU core max current (A)
          # CORE:
          # # Integrated GPU max current (A)
          # GPU:
          # # CPU cache max current (A)
          # CACHE:

          # [ICCMAX.BATTERY]
          # # CPU core max current (A)
          # CORE:
          # # Integrated GPU max current (A)
          # GPU:
          # # CPU cache max current (A)
          # CACHE:
        '';
      };
    })

  ];

}
