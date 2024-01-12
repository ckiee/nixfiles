{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ../.. ];

  cookie = {
    restic.enable = true; # Backups
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjcN4YgKxeaeQEERpYIwwZJXV3Hre4FfrD+cNi69Z6A";
      tailscaleIp = "100.124.234.25";
    };
    wireguard.ip = "10.67.75.1";
  };


  # TODO: per-server password, root too
  # users.users.ckie.hashedPassword = mkForce
  #   "changeme";
  security.sudo.wheelNeedsPassword = false;

  home-manager.users.ckie.home.stateVersion = "22.05";

  networking.hostName = "bokkusu";

  services.postgresql = {
    # This is usually also managed by stateVersion, but
    # I'm reimporting all the data so might aswell..
    package = pkgs.postgresql_14_jit;
    enableJIT = true;
    # settings.max_wal_size = "10000"; # should only be enabled for reimporting a LOOOT of data
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
