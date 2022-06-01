{ config, pkgs, lib, modulesPath, ... }:

with lib;

{
  imports = [ ../.. ./qemu.nix (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "virt";
  networking.firewall.enable = false;

  home-manager.users.ckie = { pkgs, ... }: {
    cookie.collections.devel.enable = true;
  };
  cookie = {
    desktop.enable = true;
    sound.enable = mkForce false;
    services = {
      tailscale.autoconfig = false;
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
