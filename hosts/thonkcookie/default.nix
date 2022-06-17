{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ./powersave.nix ../.. ];

  networking.hostName = "thonkcookie";

  cookie = {
    desktop = {
      enable = true;
      monitors.primary = "eDP-1";
      laptop = true;
    };
    sound = {
      pulse.enable = true;
      pipewire.enable = false;
    };
    services = {
      syncthing = {
        enable = true;
        runtimeId =
          "IE7OX5L-IH67GHS-5DDDGDY-TYHLYED-G44LTPX-YWQEQQK-6AX6OYJ-SRRWMA7";
      };
      printing.enable = true;
    };
    systemd-boot.enable = true;
    hardware.t480s.enable = true;
    smartd.enable = true;
    steam.enable = true;
    state.sshPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAC83UXW5rtEPlEqDT5c/W0DTFFwsVah6ZlCg1FO9kr";
  };
  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      collections.devel.enable = true;
      qsynth.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ zoom-us lutris ];

  programs.adb.enable = true;

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
