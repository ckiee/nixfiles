{ config, pkgs, ... }:

{
  systemd.user = {
    services.make-ron-sleep = {
      Unit = { Description = "Suspend the system so Ron sleeps"; };
      Service = { ExecStart = "${pkgs.systemd}/bin/systemctl suspend"; };
      # Install = { WantedBy = [ "default.target" ]; };
    };

    timers.make-ron-sleep = {
      Unit = {
        Description =
          "Trigger make-ron-sleep.service so Ron sleeps at a reasonable time";
      };
      Timer = {
        Persistent = false;
        OnCalendar = "*-*-* 00:30:00";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
