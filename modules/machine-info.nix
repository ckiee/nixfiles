{ lib, config, pkgs, ... }:

let cfg = config.cookie.machine-info;

in with lib; {
  options.cookie.machine-info = {
    sshPubkey = mkOption {
      type = types.nullOr types.str;
      description = "this machine's ssh_host_ed25519_key.pub";
      default = null;
    };
    tailscaleIp = mkOption {
      type = types.nullOr types.str;
      description = "this machine's Tailscale IPv4";
      default = null;
    };
  };
}
