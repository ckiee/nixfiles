{ pkgs, config, ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs-master = import sources.nixpkgs-master { };
in {
  imports =
    [ ../.. ./hardware.nix ./vfio ../../secrets/private-1.nix ./resolve.nix ];

  networking.hostName = "cookiemonster";
  cookie = {
    wireguard.num = 3;
    imperm.enable = true;
    desktop = {
      enable = true;
      monitors = {
        primary = "DP-3";
        secondary = "HDMI-1";
      };
    };

    services = {
      syncthing = {
        enable = true;
        runtimeId =
          "HPLCFJR-KBQWHAK-MWJX5HC-EXPU5LL-FZK5BB6-EO6XGCK-Q6F4TG6-W5JF7QI";
      };
      chronyc.enable =
        true; # sd-timesyncd hasn't worked correctly on this machine since ~Jul 7th
      postgres = {
        enable = true;
        # local dev
        comb.pupcat = { ensureDBOwnership = true; };
      };
    };
    restic.enable = true;
    # FIXME: This is just dirty. Syncthing is replicated yet we
    # only back up this and only through this machine..
    restic.paths = (map (x: "${config.cookie.user.home}/${x}") [
      "Sync"
      ".ssh"
      "DCIM"
      "Music"
      "git/mei.puppycat.house"
      "git/bwah.ing"
      "oldgit"
      "dna"
      ".bash_eternal_history"
      "winshare" # well we should just make it structured fr
    ]) ++ [ "/var/lib/libvirt/images/win10.qcow2" ];
    sound.pro = true;

    opentabletdriver.enable = true;
    systemd-boot.enable = true;
    wine.enable = true;
    smartd.enable = true;
    steam.enable = true;
    libvirtd.enable = true;
    mpd.enableHttp = true;
    devserv.enable = true;
    lutris.enable = true;
    ledc.enable = true;
    systemd-initrd.enable = true;
    rkvm.role = "rx";
    wol.macAddress = "50:3e:aa:05:2a:90";
    hardware.motherboard = "amd";
    openrgb.enable = true;
    # wivrn.enable = true; # FIXME: testing only
    collections.music.enable = true; # audio/music creation
    doom-emacs.standalone = true; # Imperative doom ):
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsW7gW6Ml0vCxCRLxULDWM1VMjm5eMB4tdctzQ0NUb";
      tailscaleIp = "100.66.218.84";
    };
  };

  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
      # polybar.backlight = "ddcci10"; unfortunately this is not predictable, sometimes its on 11
    };
    home.stateVersion = "22.11";
  };

  # services.mongodb.enable = true; # out-of-tree, private project

  # services.pipewire.package = with pkgs; enableDebugging pipewire;

  # Emulate aarch64-linux so we can build sd card images for drapion & pookieix
  # armv7l-linux for embedded crap
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];

  # Don't OOM on big /build-space builds.
  systemd.services.nix-daemon.environment.TMPDIR = "/nix/persist/bigtmp";

  # Setup multi-monitors; there's a 144Hz 1080p plugged into the DisplayPort,
  # and it's primary.
  services.xserver = {
    xrandrHeads = [
      {
        output = "DP-3";
        primary = true;
      }
      "HDMI-A-0"
    ];
  };

  # amd gpu opencl
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  environment.systemPackages = with pkgs; [
    prismlauncher
    kicad
    solvespace
    #
    yabridge
    yabridgectl
    #
    carla
    # mx master
    solaar
    basiliskii # old 68k mac emu
    darktable
  ];

  services.usbmuxd.enable = true;
  programs.fuse.userAllowOther = true;

  hardware.bluetooth.enable = true;

  virtualisation = {
    spiceUSBRedirection.enable = true;
    # podman =
    #   { # TODO: export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
    #     enable = true;
    #     enableNvidia = true;
    #     dockerCompat = true;
    #   };
    docker.enable = true;
  };

  programs.alvr.enable = true; # also needs unpackaged ADBForwarder or similar
  programs.droidcam.enable = true; # alternative:

  # quest link
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2833", MODE="0666"
    SUBSYSTEMS=="usb_device", ATTRS{idVendor}=="2833", MODE="0666"

    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2d40", MODE="0666"
    SUBSYSTEMS=="usb_device", ATTRS{idVendor}=="2d40", MODE="0666"
  '';

  # more quest link debug
  # hardware.opengl = let
  #   f = prev: {
  #     patches = prev.patches ++ [
  #       /home/ckie/git/mesa/0001-gallium-vl-Add-SRGB-rgb-pixel-formats.patch
  #     ];
  #   };
  # in {
  #   package = pkgs.mesa.drivers.overrideAttrs f;
  #   package32 = pkgs.pkgsi686Linux.mesa.drivers.overrideAttrs f;
  #   # unrelated:
  #   extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  # };

  # ffmpeg -i http://localhost:8080/video -flags low_delay -strict experimental -vf setpts=0 -tcp_nodelay 1 -vf format=yuv420p -f v4l2 -framerate 30 -video_size 1280x720 /dev/video0
  boot.extraModprobeConfig = "options v4l2loopback exclusive_caps=1";
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "snd-aloop" ];

  # users.users.nbsp = {
  #   isNormalUser = true;
  #   shell = pkgs.zsh;
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIeF9csiVJbQqKe2FIpYC4K/FlHATA2V+UKz+lFH+nL nbsp@voyager"
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeMPWXEczJHhA9eG8WjTNHTGPTeSL79a+7pvlno/JAW nbsp@herschel"
  #   ];
  # };

  networking.firewall.enable = false;

  services.postgresql = {
    # TODO: This is usually also managed by stateVersion, but
    package = pkgs.postgresql_16_jit;
    enableJIT = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
