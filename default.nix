{ config, pkgs, lib, ... }:

with lib;

{
  imports = [ ./modules ];
  nixpkgs = { config = { allowUnfree = true; }; };

  # I'd assume that usually the machines we're deploying to have more of
  # the store paths already downloaded since they can't GC their current
  # generation.
  deployment.substituteOnDestination = mkDefault true;

  _module.args.sources = import ./nix/sources.nix;

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" ];
  boot.tmpOnTmpfs = true; # Duh.

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  cookie.secrets.unix-password = {
    source = "./secrets/unix-password.nix";
    runtime = false;
  };

  cookie.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = (import ./secrets/unix-password.nix).ckie;
    home = "/home/ckie"; # The alias makes it think my username is "user" here.
  };

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

  home-manager.users.ckie = { pkgs, ... }: {
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
