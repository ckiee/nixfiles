{ config, pkgs, lib, ... }:

with lib;

{
  imports = [ ../.. ./hardware.nix ./windows-passthrough.nix ];

  networking.networkmanager.unmanaged = [ "enp2s0" ];
  networking = {
    hostName = "pansear";
    defaultGateway = "192.168.0.1";
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.8";
      prefixLength = 24;
    }];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # We don't have that much RAM..
  boot.tmpOnTmpfs = mkForce false;

  cookie = {
    machine-info = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhHtl6H3cAGg7paAgRoCNdI/gw36j+4zEgqsbW1vbFA root@pansear";
      tailscaleIp = "100.120.191.17";
    };
    systemd-boot.enable = true;
    smartd.enable = true;
    libvirtd.enable = true;
    restic.enable = true;
    zfs.enable = true;
    doom-emacs.enable = true;
    services = {
      avahi.enable = true;
      owo-bot.enable = true;
      ffg-bot.enable = true;
      alvr-bot.enable = true;
      daiko.enable = true;
      scanner.enableServer = true;

      printing = {
        enable = true;
        server = true;
        host = "print.atori";
      };
      aldhy = {
        enable = true;
        host = "aldhy.tailnet.ckie.dev";
      };
      nix-serve = {
        enable = true;
        host = "cache.tailnet.ckie.dev";
      };
      syncthing = {
        enable = true;
        runtimeId =
          "DFTG4YU-IGSQEVL-DZAHODV-QRXCOFP-M7OEMRP-66KHW5B-DUVNMH5-JINSLAS";
      };
    };
    tailnet-certs.client = {
      enable = true;
      hosts = [
        "aldhy.tailnet.ckie.dev"
        "cache.tailnet.ckie.dev"
        "daiko.tailnet.ckie.dev"
      ];
      forward = [ "aldhy.tailnet.ckie.dev" "daiko.tailnet.ckie.dev" ];
    };
    remote-builder.role = "builder";
    sound = {
      pulse.enable = true;
      pipewire.enable = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
