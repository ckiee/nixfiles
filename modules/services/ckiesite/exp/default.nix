{ config, lib, pkgs, ... }:

with builtins;
with lib;
with import ./html.nix { inherit lib pkgs; };

let
  cfg = config.cookie.services.ckiesite;
in {
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${cfg.host}".locations."/exp".extraConfig =
      "root ";
  };
}
