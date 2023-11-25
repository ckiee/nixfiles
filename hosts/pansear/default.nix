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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjp/gsXt35/NlIU3TtPPa4SQP3+2HWw3d5wLybegvwn root@pansear";
      tailscaleIp = "100.120.191.17";
    };
    systemd-boot.enable = true;
    smartd.enable = true;
    # libvirtd.enable = true; # breaks coredns, TODO fix..
    restic.enable = true;
    systemd-initrd.enable = true;
    # TODO: huehueuhe its not rly p2p currently it's just for prometheus
    # everything else uses tailscale
    # wireguard.endpoint = (head config.networking.interfaces.enp3s0.ipv4.addresses).address;
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
          "KGOEF25-WTH7LGU-R4AZKAP-XLS5NFP-JB6RTZY-64RC7JQ-VYQUYHP-S5G3LQ5";
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

  home-manager.users.ckie.home.stateVersion = "22.05";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
