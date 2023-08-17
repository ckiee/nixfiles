{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.chronyc;

in with lib; {
  options.cookie.services.chronyc = {
    enable = mkEnableOption
      "Enables the chrony client timesync daemon, replacing sd-timesyncd";
  };

  config = mkIf cfg.enable {
    services = {
      timesyncd.enable = false;
      chrony = {
        enable = true;
        extraFlags = [ "-r" "-s" ];
        extraConfig = ''
          # https://wiki.archlinux.org/title/Chrony#Example:_intermittently_running_desktops
          dumponexit
          dumpdir /var/lib/chrony
          rtcfile /var/lib/chrony/rtc
          #
          makestep 0.1 3
        '';
      };
    };
  };
}
