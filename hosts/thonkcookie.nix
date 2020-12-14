# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thonkcookie"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Israel";

  # Configure keymap in X11
  services.xserver.layout = "us,il";
  services.xserver.xkbOptions = "grp:win_space_toggle";
  services.xserver.libinput.naturalScrolling = true;
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Enable Xorg
  services.xserver.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraPackages = with pkgs; [
      i3blocks
      brightnessctl
      rofi
      dunst
      gnome3.gnome-screenshot
      picom
      redshift
      xorg.xmodmap
      kdeconnect
      libnotify
      xclip
      networkmanagerapplet
      sysstat
      pavucontrol
    ];
  };
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.sessionCommands =
    "sh -c 'xmodmap /home/ron/dots/xorg/.local/share/layouts/caps*'";
  services.xserver.displayManager.lightdm.greeters.gtk.iconTheme = {
    package = pkgs.paper-icon-theme;
    name = "Paper";
  };
  programs.slock.enable = true;
  fonts.fonts = with pkgs; [
    noto-fonts-emoji
    hack-font
    ubuntu_font_family
    noto-fonts
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    nano
    vscode-with-extensions
    discord
    neofetch
    stow
    firefox
    git
    kitty
    killall
    htop
  ];

  # no u stallman
  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

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

