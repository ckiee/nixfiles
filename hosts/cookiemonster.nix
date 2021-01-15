{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../modules/base.nix
    ../modules/home.nix
    ../modules/graphical.nix
  ];

  networking.hostName = "cookiemonster";

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  services.openssh.enable = true;
  services.xserver.xrandrHeads = [
    {
      output = "DP-1";
      primary = true;
    }
    "HDMI-1"
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vscode-with-extensions
    discord
    stow
    firefox
    rnix-lsp
    nixfmt
    zoom-us
    obs-studio
    weechat
    geogebra
    minecraft
    vlc
  ];

  programs.steam.enable = true;

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
