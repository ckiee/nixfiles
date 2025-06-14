{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./hardware.nix ./powersave.nix ../.. ];

  networking.hostName = "thonkcookie";

  # time.timeZone = mkForce null;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  security.sudo.wheelNeedsPassword = false; #TEMPTEMTPEMTEPMTEPTMEPTMEPTMEPm
  cookie = {
    wireguard.num = 13;
    imperm.enable = true;
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
    };
    # fprintd.enable = true; ## broken rn
    systemd-boot.enable = true;
    hardware.t480s = { enable = true; };
    smartd.enable = true;
    rkvm.role = "tx";
    steam.enable = true;
    lutris.enable = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAC83UXW5rtEPlEqDT5c/W0DTFFwsVah6ZlCg1FO9kr";
      tailscaleIp = "100.89.163.81";
    };
    doom-emacs.standalone = true; # Imperative doom ):
  };

  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
      polybar.backlight = "intel_backlight";
    };

    # option doesn't exist, TODO;
    #   services.rsibreak.package = pkgs.enableDebugging pkgs.rsibreak;
    # …this is to breakpoint
    #   bool KWindowBasedIdleTimePoller::eventFilter(QObject *object, QEvent *event)
    # in gdb.

    home.stateVersion = "23.05";
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
