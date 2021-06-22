{ config, pkgs, ... }:

# let
#   nixpkgs-local = import (/home/ckie/git/nixpkgs) { config.allowUnfree = true; };
# in
{
  imports = [ ./hardware.nix ./powersave.nix ../.. ];

  networking.hostName = "thonkcookie";

  home-manager.users.ckie = { pkgs, ... }: {
    cookie.collections.devel.enable = true;
  };
  cookie = {
    desktop = {
      enable = true;
      primaryMonitor = "eDP-1";
      laptop = true;
    };
    printing.enable = true;
    systemd-boot.enable = true;
    hardware.t480s.enable = true;
    smartd.enable = true;
    syncthing.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  environment.systemPackages = with pkgs; [ zoom-us lutris ];

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
