{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.lighttpd;

in with lib; {
  options.cookie.services.lighttpd = {
    enable = mkEnableOption "Enables the lighttpd service";
  };

  config = mkIf cfg.enable {
    services.lighttpd = {
      enable = true;
      port = 34825;
    };
  };
}
