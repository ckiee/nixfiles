# This uses blackbox on the machine hosting Prometheus to also health-check
# friends websites.
#
# https://github.com/delroth/infra.delroth.net/blob/4abea65422abcad8b13acf2669e5fd26334bc339/roles/blackbox-prober.nix#L45
# https://github.com/jtojnar/nixfiles/blob/77144f413f8ef816e9748e46193ab65daadc5424/hosts/azazel/ogion.cz/monitor/default.nix#L22
#
# This file, MIT License:
# Copyright (c) 2018 Pierre Bourdon <delroth@gmail.com>
# Copyright © 2017–2020 Jan Tojnar
# Copyright (c) 2023 ckie
#
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cookie.services.prometheus;
  mkBlackboxProbe = { module, targets, interval ? "5m" }: {
    job_name = "blackbox-${module}";
    metrics_path = "/probe";
    scrape_interval = interval;
    params.module = [ module ];
    static_configs = [{ inherit targets; }];
    # ???
    # (<ckie> i agree. i so very much agree.)
    relabel_configs = [
      {
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      }
      {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }
      {
        target_label = "__address__";
        replacement = "localhost:${
            builtins.toString config.services.prometheus.exporters.blackbox.port
          }";
      }
    ];
  };
in {
  config = mkIf cfg.enableServer {

    services.prometheus = {
      exporters.blackbox = {
        enable = true;
        configFile = pkgs.writeText "blackbox-exporter.yaml" (builtins.toJSON {
          modules = {
            https_success = {
              prober = "http";
              tcp.tls = true;
              http = {
                headers = {
                  User-Agent =
                    "blackbox-exporter (https://github.com/ckiee/nixfiles/tree/main/modules/services/prometheus/blackbox.nix)";
                };
              };
            };
          };
        });
      };
      # https://prometheus.io/docs/guides/multi-target-exporter/
      scrapeConfigs = [
        (mkBlackboxProbe {
          module = "https_success";
          targets = [
            "https://nikki.sh"
            "https://nikki.sh/notes"
            "https://nikki.sh/friends"
          ];
        })
      ];
    };
  };
}
