{ lib, config, pkgs, ... }:

with lib;
with builtins;

let cfg = config.cookie.services.postgres;

in {
  config = mkIf (cfg.enable && config.cookie.services.prometheus.enableClient) {
    cookie.services.prometheus.exporters = [{ name = "postgres"; }];
    services.prometheus.exporters.postgres = {
      enable = true;
      runAsLocalSuperUser = true;
    };
  };
}
