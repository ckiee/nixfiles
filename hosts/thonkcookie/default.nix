{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ./hardware.nix ./powersave.nix ../.. ];

  networking.hostName = "thonkcookie";

  time.timeZone = mkForce null;

  cookie = {
    desktop = {
      enable = true;
      monitors.primary = "eDP-1";
      laptop = true;
    };
    services = {
      syncthing = {
        enable = true;
        runtimeId =
          "IE7OX5L-IH67GHS-5DDDGDY-TYHLYED-G44LTPX-YWQEQQK-6AX6OYJ-SRRWMA7";
      };
      printing.enable = true;
      akkoma-test.enable = true;
    };
    systemd-boot.enable = true;
    hardware.t480s.enable = true;
    smartd.enable = true;
    rkvm.role = "tx";
    steam.enable = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAC83UXW5rtEPlEqDT5c/W0DTFFwsVah6ZlCg1FO9kr";
      tailscaleIp = "100.89.163.81";
    };
  };
  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
      polybar.backlight = "intel_backlight";
    };
    home.stateVersion = "22.11";
  };

  programs.adb.enable = true;

  hardware.bluetooth.enable = true;

  networking.firewall.enable = false;

  services.postgresql = {
    # This is usually also managed by stateVersion, but
    # I'm reimporting all the data so might aswell..
    package = pkgs.postgresql_14_jit;
    enableJIT = true;
    # settings.max_wal_size = "10000"; # should only be enabled for reimporting a LOOOT of data
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
