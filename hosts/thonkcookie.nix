{ config, pkgs, ... }:

let
  nixpkgs-local = import (/home/ron/git/nixpkgs) { config.allowUnfree = true; };
in {
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/NixOS/nixos-hardware.git";
        rev = "874830945a65ad1134aff3a5aea0cdd2e1d914ab";
      }
    }/lenovo/thinkpad/t480s"
    /etc/nixos/hardware-configuration.nix
    ../modules/base.nix
    ../modules/home.nix
    ../modules/graphical.nix
    ../modules/graphical/intel-graphics.nix
  ];

  networking.hostName = "thonkcookie";

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  environment.systemPackages = with pkgs; [
    discord
    stow
    firefox
    rnix-lsp
    nixfmt
    zoom-us
    obs-studio
    weechat
    geogebra
  ];

  nixpkgs.config.packageOverrides = pkgs: { zoom-us = nixpkgs-local.zoom-us; };

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
