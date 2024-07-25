{ config, pkgs, lib, ... }:

with lib;

# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/drapion/default.nix --argstr system aarch64-linux

{
  imports = [ ../.. ];

  cookie = {
    wireguard.ip = "10.67.75.4";
    wol.enable = true;
    restic.enable = true;
    raspberry = {
      enable = true;
      version = 3;
    };
    services = {
      avahi.enable = true;
      net-offload.enable = true;

      coredns = {
        enable = true;
        openFirewall = true;
        useLocally = true;
      };
    };
    state.sshPubkey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2azaroNAPS5GtjAqf6PdVAqEW7MgghYxlxKy+VgTH6";
  };
  home-manager.users.ckie.home.stateVersion = "22.05";

  networking.networkmanager.unmanaged = [ "eth0" ];

  # TODO: per-server password, root too
  # users.users.ckie.hashedPassword = mkForce
  #   "$y$j9T$1kqwIyYgO/PZOuTPYhW4Q/$R7oTyggU8et7h5FA1WHjliKUBAKkofqNQEQY91N5cG1";
  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "drapion";
    defaultGateway = "192.168.0.1";
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.3";
      prefixLength = 24;
    }];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
