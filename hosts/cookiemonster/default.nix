{ pkgs, config, ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs-master = import sources.nixpkgs-master { };
in {
  imports = [ ./hardware.nix ../.. ];

  # Emulate aarch64-linux so we can build sd card images for drapion & pookieix
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  cookie = {
    imperm.enable = true;
    desktop = {
      enable = true;
      monitors = {
        primary = "DisplayPort-2";
        secondary = "HDMI-A-0";
      };
    };
    services = {
      syncthing = {
        enable = true;
        runtimeId =
          "HPLCFJR-KBQWHAK-MWJX5HC-EXPU5LL-FZK5BB6-EO6XGCK-Q6F4TG6-W5JF7QI";

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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsW7gW6Ml0vCxCRLxULDWM1VMjm5eMB4tdctzQ0NUb";
      tailscaleIp = "100.66.218.84";
    };
  };
  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
    };
    home.stateVersion = "22.11";
  };

  networking.hostName = "cookiemonster";

  services.xserver = {
    xrandrHeads = [
      {
        output = "DisplayPort-2";
        primary = true;
      }
      "HDMI-A-0"
    ];
    # videoDrivers = [ "nvidia" ];
  };
  # hardware.nvidia.package =
  #   config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     mesa = final.enableDebugging prev.mesa;
  #     mesa_glu = final.enableDebugging prev.mesa_glu;
  #   })
  # ];
  #system.replaceRuntimeDependencies = [({original = pkgs.mesa; replacement = pkgs.enableDebugging pkgs.mesa;})];


  environment.systemPackages = with pkgs; [
    lutris
    picocom
    minecraft
    prismlauncher
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

  users.users.ckie.extraGroups =
    [ "adbusers" "libvirtd" "wireshark" "plugdev" ];

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
