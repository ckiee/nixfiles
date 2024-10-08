{ pkgs, config, lib, ... }:

with lib; {
  # Run socat configured as CGI
  mkCgi = exec: port:
    "${pkgs.socat}/bin/socat TCP4-LISTEN:${toString port},reuseaddr,fork EXEC:${exec}";
  # Make a service with its own user account and secure systemd settings
  #
  #  mkService "comicfury" {
  #    home = "/var/lib/comicfury";
  #    description = "ComicFury discord webhook";
  #    script =
  #      "exec ${pkgs.cookie.comicfury-discord-webhook}/bin/comicfury-discord-webhook";
  #  }
  mkService = name:
    { home ? "/var/lib/${name}", extraGroups ? [ ], description ? name, script ? "", secrets ? { }
    , wants ? [ ], noDefaultTarget ? false, path ? [], ... }: ({
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

      systemd.services."${name}" = let serviceWants = wants;
      in rec {
        inherit description script path;
        wantedBy = if noDefaultTarget then [ ] else [ "multi-user.target" ];
        requires =
          mapAttrsToList (secretName: _: "${name}-${secretName}-key.service")
          secrets ++ serviceWants;
        after = requires;

        serviceConfig = {
          User = "${name}";
          Group = "${name}";
          Restart = "on-failure";
          WorkingDirectory = "~";
          RestartSec = "10s";

          # This makes all non-kernel (e.g. devfs) filesystems read-only so we need to whitelist our ${home} path
          ProtectSystem = "strict";
          ReadWritePaths = [ home ];
          # More security: Copyright (c) 2020 Xe
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
          ProtectProc = "invisible";
          # this one causes sm pain its not worth it
          # RestrictAddressFamilies = [ "~AF_UNIX" "~AF_NETLINK" ];
          RestrictSUIDSGID = "true";
          RestrictRealtime = "true";
          LockPersonality = "true";
          SystemCallArchitectures = "native";
          ProcSubset = "pid";
          # systemd doesnt like this at all
          # SystemCallFilter = [
          #   "~@reboot"
          #   "~@module"
          #   "~@mount"
          #   "~@swap"
          #   "~@resources"
          #   "~@cpu-emulation"
          #   "~@obsolete"
          #   "~@debug"
          #   "~@privileged"
          # ];
          UMask = "077";
        };
      };
    });
}
