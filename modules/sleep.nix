{ config, lib, pkgs, ... }:

let cfg = config.cookie.sleep;
in with lib; {
  options.cookie.sleep = {
    enable = mkEnableOption "Enables the sleep-inducing service";
    sleepTime = mkOption rec {
      type = types.str;
      default = "00:30:00";
      description = "Time to make The Cookie sleep";
      example = default;
    };
  };

  systemd.user = mkIf cfg.enable {
    services.make-cookie-sleep = {
      Unit = { Description = "Suspend the system so Ron sleeps"; };
      Service = { ExecStart = "${pkgs.systemd}/bin/systemctl suspend"; };
    };

    timers.make-cookie-sleep = {
      Unit = {
        Description =
          "Trigger make-cookie-sleep.service so The Cookie sleeps at a reasonable time";
      };
      Timer = {
        Persistent = false;
        OnCalendar = "*-*-* ${cfg.sleepTime}";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
