{ config, pkgs, lib, ... }:

with lib;
with builtins;

{
  imports = [ ../.. ./hardware.nix ./windows-passthrough.nix ];

  networking.networkmanager.unmanaged = [ "enp2s0" ];
  networking = {
    hostName = "pansear";
    defaultGateway = "192.168.0.1";
    interfaces.enp3s0.ipv4.addresses = [{
      address = "192.168.0.8";
      prefixLength = 24;
    }];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # We don't have that much RAM..
  boot.tmp.useTmpfs = mkForce false;

  cookie = {
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhHtl6H3cAGg7paAgRoCNdI/gw36j+4zEgqsbW1vbFA root@pansear";
      tailscaleIp = "100.120.191.17";
    };
    systemd-boot.enable = true;
    smartd.enable = true;
    # libvirtd.enable = true; # breaks coredns, TODO fix..
    restic.enable = true;
    zfs.enable = true;
    wireguard.endpoint = (head config.networking.interfaces.enp3s0.ipv4.addresses).address;
    services = {
      avahi.enable = true;
      ffg-bot.enable = true;
      alvr-bot.enable = true;
      daiko.enable = true;
      scanner.enableServer = true;

      printing = {
        enable = true;
        server = true;
        host = "print.atori";
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
        "cache.tailnet.ckie.dev"
        "daiko.tailnet.ckie.dev"
        config.cookie.services.printing.tlsHost
      ];
      forward = [ "daiko.tailnet.ckie.dev" ];
    };
    remote-builder.role = "builder";
    sound = {
      pulse.enable = true;
      pipewire.enable = false;
    };
  };


  # dont commit this its just for archive team for the reddit fiasco
  # https://wiki.archiveteam.org/index.php/Running_Archive_Team_Projects_with_Docker
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  home-manager.users.ckie.home.stateVersion = "22.05";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
