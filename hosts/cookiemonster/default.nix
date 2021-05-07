let
in { pkgs ? import <nixpkgs>, ... }: {
  imports = [ ./hardware.nix ../.. ];
  cookie = {
    desktop = {
      enable = true;
      primaryMonitor = "DP-0";
      secondaryMonitor = "HDMI-0";
    };
    printing.enable = true;
    opentabletdriver.enable = true;
    systemd-boot.enable = true;
    sound.lowLatency = true; # for osu!
  };
  home-manager.users.ron = { pkgs, ... }: {
    cookie = {
      devel.enable = true;
    };
  };

  networking.hostName = "cookiemonster";

  services.xserver = {
    xrandrHeads = [
      {
        output = "DP-1";
        primary = true;
      }
      "HDMI-1"
    ];
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option         "nvidiaXineramaInfoOrder" "DFP-2" # this is my 144hz primary display
      Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
    '';
  };

  environment.systemPackages = with pkgs; [
    discord
    discord-ptb
    stow
    firefox
    obs-studio
    weechat
    vlc
    arandr
    spotify
    lutris
    sidequest
    steam-run-native
    prusa-slicer
    transmission-gtk
    virt-manager
    gnome3.totem
    picocom
    minecraft
    kicad-with-packages3d
    python3Packages.youtube-dl
    spotdl
    blockbench-electron
    gdb
    manpages # linux dev manpages
  ];

  programs.adb.enable = true;
  users.users.ron.extraGroups = [ "adbusers" "dialout" "libvirtd" ];

  programs.steam.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      enableNvidia = true;
      dockerCompat = true;
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
