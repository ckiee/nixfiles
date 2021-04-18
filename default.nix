{ config, pkgs, ... }:

{
  imports = [ ./modules ];
  # Users with sudo perms are cool
  nix.trustedUsers = [ "root" "@wheel" ];
  nixpkgs.config.allowUnfree = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 8d";

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" ];
  boot.tmpOnTmpfs = true; # Duh.

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

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
    };
  };

  cookie = {
    smartd.enable = true;
    avahi.enable = true;
    git.enable = true;
    syncthing.enable = true;
  };
}
