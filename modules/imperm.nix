{ lib, config, pkgs, ... }:

let cfg = config.cookie.imperm;
  sources = import ../nix/sources.nix;
in with lib; {
  options.cookie.imperm = {
    enable = mkEnableOption
      "Enables impermanence, removing the dependency for a persistent rootfs";
  };

  imports = [ "${sources.impermanence}/nixos.nix" ];
  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = {
      directories = [ "/home" "/var/log" "/var/lib/tailscale"];
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
