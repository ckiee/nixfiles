{ lib, config, pkgs, ... }:

let cfg = config.cookie.machine-info;

in with lib; {
  options.cookie.machine-info = {
    bootable = mkOption {
      type = types.bool;
      description =
        "Whether this machine needs to produce a working bootable image";
      default = cfg.sshPubkey != null;
    };
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

  config = {
    assertions = [{
      assertion = cfg.bootable -> cfg.sshPubkey != null;
      message = "bootable machines must have a cookie.machine-info.sshPubkey set";
    }];
  };
}
