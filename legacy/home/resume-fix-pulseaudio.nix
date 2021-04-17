{ config, pkgs, ... }:

{
  systemd.user.services."resume-fix-pulseaudio" = {
    Unit = {
      Description = "Fix PulseAudio after resume from suspend";
      After = [ "suspend.target" ];
    };

    Service = {
      Type = "oneshot";
      # Environment = "XDG_RUNTIME_DIR=/run/user/%U";
      ExecStart = "systemctl --user restart pulseaudio";
    };

    Install = { WantedBy = [ "suspend.target" ]; };
  };
}
