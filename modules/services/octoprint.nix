{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.octoprint;

in with lib; {
  options.cookie.services.octoprint = {
    enable = mkEnableOption "OctoPrint service";
    host = mkOption {
      description = "host for the web interface";
      type = types.str;
      default = "octo.atori";
    };
  };

  config = mkIf cfg.enable {
    services.octoprint = {
      enable = true;
      port = 5000;
    };
  };
}
