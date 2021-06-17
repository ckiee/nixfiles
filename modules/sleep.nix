{ config, lib, pkgs, ... }:

let cfg = config.cookie.sleep;
in with lib; {
  options.cookie.sleep = {
    enable = mkEnableOption "Enables the sleep-inducing service";
    sleepTime = mkOption rec {
      type = types.str;
      default = "00:15:00";
      description = "Time to make The Cookie sleep";
      example = default;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.make-cookie-sleep = {
      description = "Suspend the system so we sleep";
      script = "${pkgs.systemd}/bin/systemctl suspend";
      startAt = "*-*-* ${cfg.sleepTime}";
    };
  };
}
