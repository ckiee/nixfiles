{ config, lib, ... }:

with lib; {
  # Make a service with it's own user account and secure systemd settings
  #
  #  mkService "comicfury" {
  #    home = "/cookie/comicfury";
  #    description = "ComicFury discord webhook";
  #    script =
  #      "exec ${pkgs.cookie.comicfury-discord-webhook}/bin/comicfury-discord-webhook";
  #  }
  mkService = name:
    { home, extraGroups ? [ ], description ? name, script, secrets ? { }, ... }:
    (let userScript = script;
    in {
      users = {
        users."${name}" = {
          inherit home extraGroups description;
          createHome = true;
          isSystemUser = true;
          group = name;
        };
        groups."${name}" = { };
      };

      # We need to mkDefault secrets.*.{user,group} before adding to config.cookie.secrets
      cookie.secrets = mapAttrs' (key: value:
        nameValuePair ("${name}-${key}") (rec {
          inherit (value) source dest permissions;
          owner = mkDefault name;
          group = mkDefault name;
        })) secrets;

      systemd.services."${name}" = rec {
        inherit script description;
        wantedBy = [ "multi-user.target" ];
        wants = mapAttrsToList (name: _: "${name}-key.service") secrets;
        after = wants;

        serviceConfig = {
          User = "${name}";
          Group = "${name}";
          Restart = "on-failure";
          WorkingDirectory = "~";
          RestartSec = "10s";

          # security (stolen from @Xe, modified)
          CapabilityBoundingSet = "";
          DeviceAllow = [ ];
          NoNewPrivileges = "true";
          ProtectControlGroups = "true";
          ProtectClock = "true";
          PrivateDevices = "true";
          PrivateUsers = "true";
          PrivateTmp = "true";
          ProtectHome = "true";
          ProtectHostname = "true";
          ProtectKernelLogs = "true";
          ProtectKernelModules = "true";
          ProtectKernelTunables = "true";
          RemoveIPC = "true";
          ProtectSystem = "strict";
          ProtectProc = "invisible";
          RestrictAddressFamilies = [ "~AF_UNIX" "~AF_NETLINK" ];
          RestrictSUIDSGID = "true";
          RestrictRealtime = "true";
          LockPersonality = "true";
          SystemCallArchitectures = "native";
          ProcSubset = "pid";
          SystemCallFilter = [
            "~@reboot"
            "~@module"
            "~@mount"
            "~@swap"
            "~@resources"
            "~@cpu-emulation"
            "~@obsolete"
            "~@debug"
            "~@privileged"
          ];
          RestrictNamespaces = [
            "~CLONE_NEWCGROUP"
            "~CLONE_NEWIPC"
            "~CLONE_NEWNET"
            "~CLONE_NEWNS"
            "~CLONE_NEWPID"
            "~CLONE_NEWUTS"
            "~CLONE_NEWUSER"
          ];
          UMask = "077";
        };
      };
    });
}
