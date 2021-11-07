{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.daiko;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.daiko = {
    enable = mkEnableOption "Enables the daiko discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/daiko";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "daiko" {
      home = cfg.folder;
      description = "daiko, the crappy assistant";
      secrets.config = {
        source = "./secrets/daiko.json";
        dest = "${cfg.folder}/config.json";
        permissions = "0400";
      };
      script = let bin = pkgs.cookie.daiko;
      in ''
        exec ${bin}/bin/daiko
      '';
    })
  ]);
}
