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
      monitors = {
        primary = "DP-0";
        secondary = "HDMI-0";
      };
    };
    services = {
      syncthing = {
        enable = true;
        runtimeId =
          "MVCZQ2L-XCK3Y2Z-R7Q2UT6-TZK6CVH-WUN6TFH-I3ZOCRS-OLZAN7C-XZ4BHAF";
      };
    };
    # It doesn't work with my headphones on YT/others anymore, firefox and mpv too ):
    # update: pipewire may be glitchy, but the JACK support is worth it (:
    sound = {
      # pulse.enable = true;
      # pipewire.enable = false;
    };
    opentabletdriver.enable = true;
    systemd-boot.enable = true;
    wine.enable = true;
    smartd.enable = true;
    steam.enable = true;
    libvirtd.enable = true;
    hostapd.enable = true;
    logiops.enable = true;
    mpd.enableHttp = true;
    devserv.enable = true;
    wol.macAddress = "50:3e:aa:05:2a:90";
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPh7g9RWVnsccj2cX/LG+T6FuLMfPlNZue1g7G9O8uK3";
      tailscaleIp = "100.122.76.64";
    };
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
        output = "DP-3";
        primary = true;
      }
      "HDMI-A-1"
    ];
    # videoDrivers = [ "nvidia" ];
  };
  # hardware.nvidia.package =
  #   config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

  environment.systemPackages = with pkgs; [
    lutris
    picocom
    minecraft
    polymc
    #kicad-with-packages3d
    cookie.ledc
    x2x
  ];

  programs.cnping.enable = true;
  programs.adb.enable = true;
  programs.firejail.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };
  services.usbmuxd.enable = true;

  users.users.ckie.extraGroups = [ "adbusers" "libvirtd" "wireshark" "plugdev" ];

  virtualisation = {
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
