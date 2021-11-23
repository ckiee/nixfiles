{ pkgs, config, ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs-master = import sources.nixpkgs-master { };
in {
  imports = [ ./hardware.nix ../.. ];

  # Emulate aarch64-linux so we can build sd card images for drapion & pookieix
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  cookie = {
    desktop = {
      enable = true;
      primaryMonitor = "DP-0";
      secondaryMonitor = "HDMI-0";
    };
    services = { syncthing.enable = true; };
    opentabletdriver.enable = true;
    systemd-boot.enable = true;
    wine.enable = true;
    smartd.enable = true;
    steam.enable = true;
  };
  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
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
      Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=Off, ForceFullCompositionPipeline=Off}, DP-0: nvidia-auto-select +0+0 {ForceCompositionPipeline=Off, ForceFullCompositionPipeline=Off, AllowGSYNCCompatible=On}"
    '';
  };
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  environment.systemPackages = with pkgs; [
    lutris
    picocom
    minecraft
    kicad-with-packages3d
  ];

  programs.cnping.enable = true;
  programs.adb.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };
  users.users.ckie.extraGroups =
    [ "adbusers" "dialout" "libvirtd" "wireshark" ];

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
