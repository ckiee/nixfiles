let
  nixpkgs-local = import (/home/ron/git/nixpkgs) { config.allowUnfree = true; };
  nur-local = import (/home/ron/git/nur-a-repo) { };
  nixpkgs-steam =
    import (/home/ron/git/luigi-nixpkgs) { config.allowUnfree = true; };
in { config, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../../modules/base.nix
    ../../modules/home.nix
    ../../modules/graphical.nix
    ../../modules/smartd.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "cookiemonster";

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  services.xserver.xrandrHeads = [
    {
      output = "DP-1";
      primary = true;
    }
    "HDMI-1"
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''
    Option         "nvidiaXineramaInfoOrder" "DFP-2" # this is my 144hz primary display
    Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
  '';

  home-manager.users.ron = { pkgs, ... }: {
    imports = [ ../../modules/home/sleep.nix ];
  };

  environment.systemPackages = with pkgs; [
    discord
    stow
    firefox-esr
    zoom-us
    obs-studio
    weechat
    geogebra
    minecraft
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
    nur-local.pmbootstrap
    virt-manager
  ];

  nixpkgs.config.packageOverrides = pkgs: { zoom-us = nixpkgs-local.zoom-us; };
  # nixpkgs.overlays = [ (self: super: { steam = nixpkgs-steam.steam; }) ];

  programs.adb.enable = true;
  users.users.ron.extraGroups = [ "adbusers" "dialout" "libvirtd" ];
  hardware.opentabletdriver = { enable = true; };
  programs.steam.enable = true;
  virtualisation.libvirtd.enable = true;

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
