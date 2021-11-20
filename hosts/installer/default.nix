{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../..
    ./install.nix
  ];

  networking = {
    hostName = "installer";
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  services.getty.autologinUser = mkForce "ckie";
  users.users.ckie.hashedPassword = mkForce "";

  cookie = {
    systemd-boot.enable = true;
    services = {
      avahi.enable = true;
      tailscale.enable = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
