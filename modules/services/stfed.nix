{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.stfed;

  format = pkgs.formats.toml { };
  hooksToml = format.generate "hooks.toml" { hooks = cfg.hooks; };
in with lib; {
  options.cookie.services.stfed = {
    enable = mkEnableOption "stfed service";

    hooks = mkOption {
      type = types.listOf format.type;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.stfed = {
      description = "Syncthing Folder Event Daemon";
      partOf = [ "syncthing.service" ];
      after = [ "syncthing.service" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ hooksToml ];

      serviceConfig = {
        ExecStart = "${getBin pkgs.stfed}/bin/stfed";
        User = "ckie";
        Group = "syncthing";

        SystemCallArchitectures = "native";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = false; # we run sudo in this lol

        Restart = "always";
        RestartSec = "10s";
      };
    };

    environment.etc."xdg/stfed/hooks.toml".source = hooksToml;

  };
}
