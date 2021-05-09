{ config, pkgs, ... }:

{
  imports = [ ./modules ];
  nixpkgs.config.allowUnfree = true;
  # Users with sudo perms are cool
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 8d";
      dates = "weekly";
    };
    autoOptimiseStore = true;
    trustedUsers = [ "root" "@wheel" ];
  };

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" ];
  boot.tmpOnTmpfs = true; # Duh.

  networking.networkmanager.enable = true;
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  users.users.ron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ (builtins.readFile ./ext/id_rsa.pub) ];
    initialPassword = "cookie";
  };

  # Some bare basics
  environment.systemPackages = with pkgs; [
    wget
    vim
    tree
    neofetch
    git
    killall
    htop
    file
    inetutils
    binutils-unwrapped
    pciutils
    usbutils
  ];

  home-manager.users.ron = { pkgs, ... }: {
    cookie = {
      bash.enable = true;
      nixpkgs-config.enable = true;
    };
  };

  cookie = {
    smartd.enable = true;
    avahi.enable = true;
    git.enable = true;
    syncthing.enable = true;
    binaryCaches.enable = true;
  };
}
