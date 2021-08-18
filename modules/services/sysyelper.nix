{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.sysyelper;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.sysyelper = {
    enable = mkEnableOption "Enables the sysyelper discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/sysyelper";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "sysyelper" {
      home = cfg.folder;
      description = "sysyelper discord bot";
      secrets.env = {
        source = "./secrets/sysyelper.env";
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      script = let sys = pkgs.cookie.sysyelper;
      in ''
        ln -sf ${sys}/libexec/sysyelper/deps/sysyelper/.env.example .env.example
        exec ${sys}/bin/sysyelper
      '';
    })
  ]);
}
