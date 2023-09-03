{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.elastic;

in with lib; {
  options.cookie.services.elastic = {
    enable = mkEnableOption "ElasticSearch service";
  };

  config = mkIf cfg.enable {
    services.elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
    };
  };
}
