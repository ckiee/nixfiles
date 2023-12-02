{ config, lib, pkgs, util, ... }:

with lib;

let
  cfg = config.cookie.services.prometheus;
  inherit (util) mkRequiresScript;
in {
  # TODO: stop checking on other modules being enabled..
  config = mkIf (cfg.enableClient && config.cookie.smartd.enable) {
    # assumption: /var/lib/prometheus-node-exporter-text-files, from default.nix
    systemd.services.prometheus-smartctl-text-file = {
      description = "smartctl to Prometheus textfile";
      startAt = "*-*-* *:*:21";
      script = ''
        mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
        cd /var/lib/prometheus-node-exporter-text-files
        ${mkRequiresScript ./smartmon.sh} > smartmon.prom.next
        mv smartmon.prom{.next,}
      '';
    };
  };
}
