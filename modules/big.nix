{ lib, config, pkgs, ... }:

let cfg = config.cookie.big;

in with lib; {
  options.cookie.big = {
    enable = mkEnableOption "Enables common things for big machines" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
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
      ncdu_1 # _2 only supports modern microarchs
      fd # a better find
      hyperfine # a better time
      mtr # a better traceroute
      tmux # when you can't afford i3
      youtube-dl
      yt-dlp # do some pretendin' and fetch videos
      jq # like 'node -e' but nicer
      btop # htop on steroids
      expect # color capture, galore
      caddy # convenient bloated web server
      parallel # --citation
    ];

    services.fwupd.enable = true;

    boot.initrd.supportedFilesystems = [ "ntfs" "btrfs" ];

    cookie = {
      # Daemons
      services = {
        coredns = {
          enable = true;
          useLocally = true;
        };
      };
      # Etc
      wireguard.enable = config.cookie.state.bootable;
      binary-caches.enable = true;
      nix.enable = true;
      git.enable = true;
      cookie-overlay.enable = true;
      ipban.enable = true;
      shell-utils.enable = true;
    };
    home-manager.users.ckie = { nixosConfig, pkgs, ... }: {
      cookie = { shell.fish = true; };
    };
  };
}
