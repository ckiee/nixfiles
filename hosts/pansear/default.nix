{ config, pkgs, lib, ... }:

with lib;

{
  imports = [ ../.. ./hardware.nix ./windows-passthrough.nix ];

  networking.hostName = "pansear";

  cookie = {
    machine-info.sshPubkey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhHtl6H3cAGg7paAgRoCNdI/gw36j+4zEgqsbW1vbFA root@pansear";
    systemd-boot.enable = true;
    smartd.enable = true;
    libvirtd.enable = true;
    services = { avahi.enable = true; };
    remote-builder.role = "builder";
    sound = {
      pulse.enable = true;
      pipewire.enable = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}