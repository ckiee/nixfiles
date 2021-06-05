{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.monitoring;

in with lib; {
  options.cookie.collections.monitoring = {
    enable = mkEnableOption "Enables the monitoring collection";
  };

  config = mkIf cfg.enable {
    cookie.services = {
      grafana.enable = true;
      prometheus.enable = true;
    };
  };
}
