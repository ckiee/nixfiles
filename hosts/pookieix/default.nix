{ config, pkgs, lib, ... }:

with lib;
# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/pookieix/default.nix --argstr system aarch64-linux

{
  imports = [ ./hardware.nix ../.. ];

  networking = {
    hostName = "pookieix";
    firewall.enable = false;
  };

  cookie = {
    wireguard.num = 12;
    raspberry = {
      enable = true;
      version = 4;
    };
    services = {
      avahi.enable = true;
      # octoprint.enable = true;
      coredns.enable = mkForce
        false; # this RPi does not have a hardware rtc AND doesn't run 24/7 which makes it a pain in the ass for TLS
      scanner.enable = mkForce false;
    };
    networkmanager.enable = mkForce false; # TODO
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH2IOYTUc8hAiuvGs2quG4dRZq2ubskdqN0t80zl+OA root@pookieix";
      tailscaleIp = "100.64.158.85";
    };
  };

  networking.wireguard.interfaces.cknet.dynamicEndpointRefreshSeconds = 5;

  home-manager.users.ckie = { ... }: { home.stateVersion = "23.05"; };

  security.sudo.wheelNeedsPassword = false;

  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  nixpkgs.overlays = singleton (final: prev: {
    inherit (import prev.path {
      allowUnfree = true;
      system = "x86_64-linux";
    })
      brscan5 sane-backends;
  });

  hardware.sane = {
    enable = true;
    brscan5 = {
      enable = true;
      netDevices.drora = {
        ip = "10.100.102.10";
        model = "MFC-J470DW";
      };
    };
    netConf = "10.100.102.10";
  };

  systemd.services."rfkill-it" = {
    wantedBy = [ "multi-user.target" ];
    description = "dont need the modem";
    path = [ pkgs.rfkill_udev ];
    script = ''
      rfkill block bluetooth
      rfkill block wlan
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
