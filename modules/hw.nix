{ config, lib, pkgs, ... }:

let cfg = config.cookie.hardware;
in with lib; {
  options.cookie.hardware = {
    t480s = {
      enable = mkEnableOption "Enables Thinkpad T480s specific hardware quirks";
      undervolt = mkEnableOption "Enables Thinkpad T480s CPU undervolting";
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
          Option "Tapping" "off"
        EndSection
      '');

      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';
    })
    (mkIf cfg.t480s.undervolt {
      services.throttled = {
        enable = true;
        # this overrides the default t480s stuff so just temp:
        extraConfig = ''
          [UNDERVOLT]
          # CPU core voltage offset (mV)
          CORE: -60
          # Integrated GPU voltage offset (mV)
          GPU: -85
          # CPU cache voltage offset (mV)
          CACHE: -105
          # System Agent voltage offset (mV)
          UNCORE: -85
          # Analog I/O voltage offset (mV)
          ANALOGIO: 0'';
      };
    })
  ];

}
