{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.jitsi;

in with lib; {
  options.cookie.services.jitsi = {
    enable = mkEnableOption "Enables the Jitsi service";
  };

  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      nginx.enable = true;
      hostName = "jitsi.ckie.dev";
      interfaceConfig = {
        SHOW_JITSI_WATERMARK = false;
        SHOW_WATERMARK_FOR_GUESTS = false;
      };
    };
  };
}
