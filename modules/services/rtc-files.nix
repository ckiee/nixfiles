{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.rtc-files;

in with lib; {
  options.cookie.services.rtc-files = {
    enable = mkEnableOption "Enables rtc-files service";
    host = mkOption {
      type = types.str;
      default = "devel.i.ronthecookie.me";
      description = "the host. wow.";
      example = "i.ronthecookie.me";
    };
    redirect = mkOption {
      type = types.str;
      default = "ronthecookie.me";
      description = "host to redirect / to";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    system.activationScripts = {
      rtc-files-mkdir.text = ''
        mkdir -p /cookie/rtc-files || true

        # nginx writes, ron reads
        chmod 740 /cookie/rtc-files
        chown ron:nginx /cookie/rtc-files
      '';
    };

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { root = "/cookie/rtc-files"; };
        extraConfig = "rewrite ^/$ $scheme://${cfg.redirect} permanent;";
      };
    };
  };
}
