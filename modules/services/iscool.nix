{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.iscool;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.iscool = {
    enable = mkEnableOption "Enables the Iscool alerting service";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/iscool";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "iscool" {
      home = cfg.folder;
      description = "Iscool alerting service";
      secrets.env = {
        source = "./secrets/iscool.env";
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      script = ''
        ln -sf ${pkgs.cookie.iscool}/libexec/iscool/deps/iscool/.env.example .env.example
        exec ${pkgs.cookie.iscool}/bin/iscool
      '';
      noDefaultTarget = true; # don't run the service on boot
    })
    {
      systemd.services.iscool = {
        serviceConfig.Type = "oneshot";
        startAt = "*-*-* 18:30:00";
      };
    }
  ]);
}
