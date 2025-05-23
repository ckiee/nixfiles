{ lib, config, pkgs, ... }:

let cfg = config.cookie.big;

in with lib; {
  options.cookie.big = {
    enable = mkEnableOption "Enables common things for big machines" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # TODO: some of these clearly don't belong on a server!!! like bokkusu doens't need yt-dlp
    environment.systemPackages = with pkgs; [
      tree
      neofetch
      git
      killall
      htop
      file
      inetutils
      binutils-unwrapped
      psmisc
      pciutils
      usbutils
      dig
      dogdns # like dig but nicer output
      asciinema
      # ripgrep # a better grep -- also in default.nix
      unzip
      ncdu_1 # _2 only supports modern microarchs
      fd # a better find
      hyperfine # a better time
      mtr # a better traceroute
      yt-dlp # do some pretendin' and fetch videos
      jq # like 'node -e' but nicer
      # btop # htop on steroids -- now also in default.nix (it's that good)
      expect # color capture, galore
      caddy # convenient bloated web server
      parallel # --citation
      nix-tree # nix what-depends why-depends who-am-i
      picocom # bbaauuddrraattee
      cp210x-program # program lil usb serial interfaces (: really cool actually..
      x2x # mouse/keyboard, remotely
      cntr # get a shell inside ~any container. great thing but --help is kinda broken.
      nix-output-monitor # see what da nix builds r up to
      mommy # mommy's here to support you, in any shell, on any system~ ❤️
      imagemagick # image swiss army knife, incls $out/bin/convert
      graphviz # draw graphs w a dsl!
      bat # syntax highlight anything, cat clone. e.g$ strace gource |& bat -pl strace --no-pager
      libqalculate # qalc, https://fedi.cassilda.house/objects/6db95278-26bb-4818-b89f-feb2d7b77963
      cookie.bandcamp-dl # ili's bandcamp downloaber ( requires account. watch out for https://github.com/borisbabic/browser_cookie3/pull/126 )
      wemux # tmux multiplayer pubnix-style
      powertop # power efficency! batteries! laptop!
      fatrace # fs-wide access trace
      dua # like du but faster
      cyme # better 'lsusb'
      wormhole-rs
      xdotool
      rclone # better rsync ± storage providers
      jwhois
      p7zip
      poppler_utils # pdfunite for concating pdfs
      phoon # phase of the moon (:
      pandoc # convert.. CONVERt.. CONVERTTT!
      delta # prettydiff
      bluetui
      pigz # haven't tried: tar -c --use-compress-program=pigz -f tar.file dir_to_zip
    ];

    services.fwupd.enable = true;

    boot = {
      initrd.supportedFilesystems = [ "ntfs" "btrfs" ];
      supportedFilesystems = [ "ntfs" ];
    };

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
      firejail.enable = true;
    };
    home-manager.users.ckie = { nixosConfig, pkgs, ... }: {
      cookie = {
        shell.fish = true;
        tmux.enable = true; # when you can't afford i3
      };
    };
  };
}
