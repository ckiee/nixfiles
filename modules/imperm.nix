{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.imperm;
  sources = import ../nix/sources.nix;
in with lib; {
  options.cookie.imperm = {
    enable = mkEnableOption
      "Enables impermanence, removing the dependency for a persistent rootfs";
  };

  imports = [ "${toString sources.impermanence}/nixos.nix" ];
  config = mkIf cfg.enable {
    # TODO split out into relevant modules, we probably want to make our own options
    # and mkIf-passthrough in here instead of mkIf everywhere.. better introspectability
    environment.persistence."/nix/persist" = {
      directories = [
        "/home"
        "/var/log"
        "/var/lib/tailscale"
        "/var/lib/libvirt"
        config.services.mongodb.dbpath
        "/var/lib/alsa" # volume sliders, sometimes muted by default, but depends on plugged in hardware
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };

}
