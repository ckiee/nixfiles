{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ./network.nix ../.. ];
  networking.hostName = "crobat";

  cookie = {
    wireguard = {
      num = 15;
      endpoint = "crobat.ckie.dev";
      v6TunnelEndpoint = true;
    };
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQJIywDbF+KXtfqN5n6ko4jqnbPbnMu0kG+YGLULFRo root@crobat";
      tailscaleIp = "100.94.244.90";
    };
  };
  security.sudo.wheelNeedsPassword = false;

  networking.firewall.logRefusedConnections = mkForce true;

  # used as v6 tunnel
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  home-manager.users.ckie.home.stateVersion = "23.11";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
