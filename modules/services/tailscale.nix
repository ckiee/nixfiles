{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.tailscale;
  tailscale = config.services.tailscale.package;
in with lib; {
  options.cookie.services.tailscale = {
    enable =
      mkEnableOption "Enables and autoconfigures the Tailscale client daemon";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

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

      serviceConfig.Type = "oneshot";

      script =
        "${tailscale}/bin/tailscale up --reset --force-reauth --authkey $(cat ${
          escapeShellArg config.cookie.secrets.tailscale-authkey.dest
        })";
    };
  };
}
