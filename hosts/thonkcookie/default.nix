{ config, pkgs, ... }:

let
  nixpkgs-local = import (/home/ron/git/nixpkgs) { config.allowUnfree = true; };
in {
  imports = [
    ./hardware.nix
    ./powersave.nix
    ../../legacy/base.nix
    ../../legacy/graphical.nix
    ../../legacy/graphical/intel-graphics.nix
    ../../legacy/printer.nix
    ../../modules
  ];

  networking.hostName = "thonkcookie";

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
  };

  environment.systemPackages = with pkgs; [
    discord
    firefox
    zoom-us
    weechat
    lutris
  ];

  programs.adb.enable = true;
  # nixpkgs.config.packageOverrides = pkgs: { zoom-us = nixpkgs-local.zoom-us; };

  cookie.polybar = {
    laptop = true;
    primaryMonitor = "eDP-1";
  };
  cookie.hw.t480s = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
