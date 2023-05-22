{ util, config, lib, pkgs, nixosConfig, ... }:

with lib;
with builtins;

let cfg = config.cookie.i3;
in {
  config = mkIf cfg.enable {
    # This replaces the ~/.xsession systemctl start call with a systemd service for running i3,
    # If we used sway, then this would be easier as sway-session.target is already defined in HM.
    #
    # See https://github.com/nix-community/home-manager/issues/3818
    #
    # we will not be launching i3 directly from ~/.xsession:
    # (check out HM xsession for ctx)
    xsession.windowManager.command = mkForce "systemctl --user start --wait hm-graphical-session.target";
    # instead, a systemd service:

    systemd.user.services.i3wm = {
      Unit = {
        Description = "Home Manager i3wm";
        # TODO: really, this should be hm-graphical-session [i3wm] -> graphical-session{-pre,}, but that requires more refactoring, so no.
        PartOf = [ "graphical-session-pre.target" ];
        BindsTo = [ "graphical-session-pre.target" ];
        Before = [ "tray.target" ];
      };
      Install.WantedBy = [ "graphical-session-pre.target" ];

      Service = {
        ExecStart = "${config.xsession.windowManager.i3.package}/bin/i3";
        Type = "notify";
        NotifyAccess = "all";
        # unit that should not be restarted even if a change has been detected.
        # https://github.com/nix-community/home-manager/blob/669669fcb403e3137dfe599bbcc26e60502c3543/modules/systemd-activate.rb#L181-L182
        X-RestartIfChanged = false;
        # i3 can start other user apps that may not be so graceful. complicated behaviour:
        # https://www.freedesktop.org/software/systemd/man/systemd.kill.html
        KillMode = "mixed";

        # TODO if upstreamed(?): ExecReload through this mechanism? check HM i3 module for current activation mechanism
      };
    };
  };
}

