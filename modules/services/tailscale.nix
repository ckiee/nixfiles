{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.tailscale;
  tailscale = config.services.tailscale.package;
in with lib; {
  options.cookie.services.tailscale = {
    enable = mkEnableOption "Tailscale client daemon";
    autoconfig = mkOption {
      type = types.bool;
      default = true;
      description = "Autoconfigure tailscaled";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.tailscale.enable = true;
      # Disable spooky auto `lsof` publishing toggled remotely by controlplane:
      systemd.services.tailscaled.environment.TS_DEBUG_DISABLE_PORTLIST = "1";
      # https://tailscale.com/kb/1082/firewall-ports/#my-devices-are-using-a-relay-what-can-i-do-to-help-them-connect-peer-to-peer
      networking.firewall = {
        allowedTCPPorts = [ 41641 ];
        allowedUDPPorts = [ 41641 ];
      };
    })

    (mkIf (cfg.enable && cfg.autoconfig) {
      cookie.secrets.tailscale-authkey = {
        source = "./secrets/tailscale-authkey";
        owner = "root";
        group = "root";
        permissions = "0400";
        wantedBy = "tailscaled-autoconfig.service";
      };

      systemd.services.tailscaled-autoconfig = rec {
        description = "Autoconfigure tailscaled";
        wantedBy = [ "multi-user.target" ];
        requires = [ "tailscaled.service" "tailscale-authkey-key.service" ];
        after = requires;

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        # Don't rerun `up` if we're already running.
        # Haven't tested what BackendState indicates thoroughly.
        script = ''
          tailscale status --json | jq -r .BackendState | grep -q Running \
          || ${tailscale}/bin/tailscale up \
            --reset --authkey file:${
              escapeShellArg config.cookie.secrets.tailscale-authkey.dest
            }
        '';
      };
    })
  ];
}
