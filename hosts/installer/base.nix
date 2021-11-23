{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../..
    #_#./hardware.nix
  ];

  networking.hostName = "CHANGE_HOST";

  cookie = {
    systemd-boot.enable = true;
    services = {
      avahi.enable = true;
      tailscale.autoconfig = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #
  # (ckie): this is kept at 20.09 as that is the oldest stateVersion in
  # our fleet currently.
  system.stateVersion = "20.09"; # Did you read the comment?
}
