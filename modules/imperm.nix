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
        "/var/lib/alsa" # volume sliders, sometimes muted by default, but depends on plugged in hardware, also scarlett 4i4 state
        "/var/lib/bluetooth"
        "/etc/NetworkManager/system-connections"
        "/var/cache/powertop"
        "/var/www/websync" # TODO: move back out into modules/services/websync.nix once this module can passthru dirs/files
        "/var/lib/docker" #,,,, lost a lot of data to this being missing
        "/var/lib/daiko"
        "/var/lib/nixos"
        "/var/lib/postgresql"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        # https://github.com/systemd/systemd/issues/13183 ):
        # "/etc/localtime" # Timezone on timezone-dynamic machines (e.g. thonkcookie)
      ];
    };
  };

}
