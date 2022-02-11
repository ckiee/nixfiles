{ config, pkgs, lib, sources, ... }:

with lib;
with builtins;

{
  imports = [ ./modules ];
  nixpkgs.config.allowUnfree = true;
  system = {
    configurationRevision = getEnv "CKIE_CONFIG_REV";
    nixos.revision = sources.nixpkgs.rev;
  };

  _module.args.sources = import ./nix/sources.nix;

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" "btrfs" ];
  boot.tmpOnTmpfs = true; # Duh.

  networking.networkmanager.enable = true;

  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = (import ./secrets/unix-password.nix).root;
  };

  # Nasty obscure EBUSY errors will come without this
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile"; # max FD count
    value = "unlimited";
  }];

  # Prune the journal to avoid this:
  # $ du -sh /var/log/journal/
  # 4.1G    /var/log/journal/
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    MaxFileSec=7day
  '';

  services.fwupd.enable = true;

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
    ripgrep # a better grep
    unzip
    ncdu
    fd # a better find
    hyperfine # a better time
    mtr # a better traceroute
    tmux # when you can't afford i3
    youtube-dl
    yt-dlp # do some pretendin' and fetch videos
    jq # like 'node -e' but nicer
    btop # htop on steroids
  ];

  cookie = {
    # Daemons
    services = {
      ssh.enable = true;
      tailscale.enable = mkDefault true;
      coredns = {
        enable = true;
        useLocally = true;
      };
    };
    # Etc
    git.enable = true;
    binaryCaches.enable = true;
    nix.enable = true;
    cookie-overlay.enable = true;
    ipban.enable = true;
    shell-utils.enable = true;
    zfs.enable = true;
  };

  home-manager.users.ckie = { nixosConfig, pkgs, ... }: {
    # for hmporter support
    home.sessionVariables.TZ = nixosConfig.time.timeZone;
    cookie = {
      shell = {
        enable = true;
        bash = true;
        fish = true;
      };
      nixpkgs-config.enable = true;
    };
  };
}
