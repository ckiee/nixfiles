{ config, pkgs, lib, ... }:

with lib;
# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/pookieix/default.nix --argstr system aarch64-linux

{
  imports = [ ./hardware.nix ../.. ];

  networking = {
    hostName = "pookieix";
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  cookie = {
    raspberry = {
      enable = true;
      version = 4;
    };
    services = {
      avahi.enable = true;
      octoprint.enable = true;
      coredns.enable = mkForce
        false; # this RPi does not have a hardware rtc AND doesn't run 24/7 which makes it a pain in the ass for TLS
    };
    state.sshPubkey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBacSyNUF7XfWbo4nUuG0DLha+cHReyCm2zeBZcRaYLy";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
