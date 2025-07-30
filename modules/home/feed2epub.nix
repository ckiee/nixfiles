{ lib, config, pkgs, ... }:

let cfg = config.cookie.feed2epub;

in with lib; {
  options.cookie.feed2epub = { enable = mkEnableOption "Enables feed2epub"; };

  config = mkIf cfg.enable {

    systemd.user.services.feed2epub = {
      Unit = { Description = "feed2epub"; };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "feed2epub-svc" ''
          ${pkgs.cookie.feed2epub}/bin/feed2epub-ck -o ~/Sync/Calibre/AAA_rss.epub ${
            concatStringsSep " "
            (map (x: "'${x}'") [ "http://necroepilogos.net/feed" ])
          }
        '';
      };
    };

    systemd.user.timers.feed2epub = {
      Unit.Description = "feed2epub";
      Timer = {
        OnCalendar = "hourly";
        Unit = "feed2epub.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };

  };
}
