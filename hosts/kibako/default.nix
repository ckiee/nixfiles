{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ../.. ];
  networking.hostName = "kibako";

  cookie = {
    restic.enable = true; # Backups
    systemd-initrd.enable = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAV1Zlysa7J4BRpYtZLHStkGIOnGpS0KQWNFf9Tlds4 root@rescue-customer-eu";
      # tailscaleIp = "";
    };
    # wireguard = {
    #   endpoint = "kibako.ckie.dev";
    # };
    # services = {
    #   ckiesite = {
    #     enable = true;
    #     host = "ckie.dev";
    #   };
    # };
    # acme = {
    #   enable = true;
    #   hosts = {
    #     "ckie.dev" = {
    #       provider = "porkbun";
    #       extras = [];
    #     };
    #   };
    # };
  };

  networking.networkmanager.enable = mkForce false;
  networking.dhcpcd.enable = false;
  services.resolved.enable = false; # systemd does not get to manage our DNS.
  systemd.network = {
    enable = true;
    networks.eth0 = {
      matchConfig.Name = "e*"; # eth0, eno0, or sometimes 1?
      addresses = map (addr: { addressConfig.Address = addr; }) [
        "37.187.95.216/24"
        "2001:41d0:a:37d8::1/128"
      ];
      gateway = [ "37.187.95.254" "2001:41d0:a:37ff:ff:ff:ff:ff" ];
      networkConfig = {
        DHCP = "no"; # is default
      };
    };
  };

  boot.initrd.systemd.network.networks.eth0 =
    config.systemd.network.networks.eth0;

  home-manager.users.ckie.home.stateVersion = "23.05";

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
