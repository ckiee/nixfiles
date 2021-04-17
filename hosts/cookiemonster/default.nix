let
  #  nixpkgs-local = import (/home/ron/git/nixpkgs) { config.allowUnfree = true; };
  #  nur-local = import (/home/ron/git/nur-a-repo) { };
  #  nixpkgs-steam =
  #   import (/home/ron/git/luigi-nixpkgs) { config.allowUnfree = true; };
in { pkgs ? <nixpkgs>, ... }: {
  imports = [
    ./hardware.nix
    ../../legacy/base.nix
    ../../legacy/home.nix
    ../../legacy/graphical.nix
    ../../legacy/smartd.nix
    ../../legacy/pulse-lowlatency.nix
    ../../legacy/printer.nix
    ../../modules
  ];
  home-manager.users.ron = { pkgs, ... }: {
    imports = [ ../../legacy/home/sleep.nix ];
    cookie.polybar = {
      enable = true;
      secondaryMonitor = "HDMI-0";
    };
  };

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "fakemonster";

  # services.xserver = {
  #   xrandrHeads = [
  #     {
  #       output = "DP-1";
  #       primary = true;
  #     }
  #     "HDMI-1"
  #   ];
  #   videoDrivers = [ "nvidia" ];
  #   screenSection = ''
  #     Option         "nvidiaXineramaInfoOrder" "DFP-2" # this is my 144hz primary display
  #     Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
  #   '';
  # };

  environment.systemPackages = with pkgs; [
    discord
    discord-ptb
    stow
    firefox
    obs-studio
    weechat
    geogebra
    vlc
    arandr
    spotify
    lutris
    sidequest
    steam-run-native
    maven
    rustup
    prusa-slicer
    platformio
    transmission-gtk
    #nur-local.pmbootstrap
    virt-manager
    gnome3.totem
    gcc
    picocom
    minecraft
    kicad-with-packages3d
    python3Packages.youtube-dl
    # (pkgs.callPackage ./immersed.nix { })
    blockbench-electron
    gdb
    manpages # linux dev manpages
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.extraModulePackages = [ nixpkgs-local.linuxPackages_zen.evdi ];

  programs.adb.enable = true;
  users.users.ron.extraGroups = [ "adbusers" "dialout" "libvirtd" ];
  hardware.opentabletdriver.enable = true;
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
