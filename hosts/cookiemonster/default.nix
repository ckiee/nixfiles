{ pkgs, config, ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs-master = import sources.nixpkgs-master { };
in {
  imports = [ ../.. ./hardware.nix ./vfio ../../secrets/private-1.nix ];

  networking.hostName = "cookiemonster";
  cookie = {
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
    };
    restic.enable = true;
    # FIXME: This is just dirty. Syncthing is replicated yet we
    # only back up this and only through this machine..
    restic.paths = map (x: "${config.cookie.user.home}/${x}") [ "Sync" ".ssh" "DCIM" "Music" ];
    sound.pro = true;

    opentabletdriver.enable = true;
    systemd-boot.enable = true;
    wine.enable = true;
    smartd.enable = true;
    steam.enable = true;
    libvirtd.enable = true;
    hostapd.enable = true;
    mpd.enableHttp = true;
    devserv.enable = true;
    lutris.enable = true;
    ledc.enable = true;
    systemd-initrd.enable = true;
    rkvm.role = "rx";
    wol.macAddress = "50:3e:aa:05:2a:90";
    hardware.motherboard = "amd";
    openrgb.enable = true;
    wivrn.enable = true; # FIXME: testing only
    collections.music.enable = true; # audio/music creation
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

  services.mongodb.enable = true; # out-of-tree, private project

  # services.pipewire.package = with pkgs; enableDebugging pipewire;

  # Emulate aarch64-linux so we can build sd card images for drapion & pookieix
  # armv7l-linux for embedded crap
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];

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
    minecraft
    prismlauncher
    # kicad-with-packages3d
    solvespace
    heroic
    #
    yabridge
    yabridgectl
    #
    carla
    # mx master
    solaar
  ];

  services.usbmuxd.enable = true;
  programs.droidcam.enable = true;
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
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
