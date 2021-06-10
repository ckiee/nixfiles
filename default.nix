{ config, pkgs, ... }:

{
  imports = [ ./modules ];
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 8d";
      dates = "weekly";
    };
    autoOptimiseStore = true;
    trustedUsers = [ "root" "@wheel" ];
  };
  nixpkgs = { config = { allowUnfree = true; }; };

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" ];
  boot.tmpOnTmpfs = true; # Duh.

  networking.networkmanager.enable = true;

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
    dig
    asciinema
  ];

  cookie = {
    # Daemons
    services.ssh.enable = true;
    # Etc
    git.enable = true;
    binaryCaches.enable = true;
    nix-path.enable = true;
    cookie-overlay.enable = true;
    ipban.enable = true;
  };

  home-manager.users.ron = { pkgs, ... }: {
    cookie = {
      bash.enable = true;
      nixpkgs-config.enable = true;
    };
  };
}
