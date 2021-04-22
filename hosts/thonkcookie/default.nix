{ config, pkgs, ... }:

# let
#   nixpkgs-local = import (/home/ron/git/nixpkgs) { config.allowUnfree = true; };
# in
{
  imports = [ ./hardware.nix ./powersave.nix ../.. ];

  networking.hostName = "thonkcookie";

  home-manager.users.ron = { pkgs, ... }: {
    cookie = { polybar.laptop = true; };
  };
  cookie = {
    desktop.enable = true;
    printing.enable = true;
    systemd-boot.enable = true;
    hardware.t480s = true;
  };

  environment.systemPackages = with pkgs; [
    discord
    discord-ptb
    firefox
    zoom-us
    weechat
    lutris
    rustup
    gcc
  ];

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
