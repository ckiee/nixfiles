{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.jitsi;

in with lib; {
  options.cookie.services.jitsi = {
    enable = mkEnableOption "Enables the Jitsi service";
    host = mkOption {
      type = types.nullOr types.str;
      example = "jitsi.ckie.dev";
      description = "host for the web interface";
    };
  };

  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      nginx.enable = true;
      hostName = cfg.host;
      interfaceConfig = {
        SHOW_JITSI_WATERMARK = false;
        SHOW_WATERMARK_FOR_GUESTS = false;
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      enableACME = false;
    };
  };
}
