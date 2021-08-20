{ config, pkgs, lib, ... }:

with lib;

# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/drapion/default.nix --argstr system aarch64-linux
# nix copy --to ssh://drapion.local $(nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=hosts/drapion/default.nix --argstr system aarch64-linux)
{
  imports =
    [ ../.. <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix> ];

  cookie = {
    services = {
      avahi.enable = true;
      coredns = {
        enable = true;
        openFirewall = true;
      };
    };
  };

  networking.networkmanager.enable = mkForce false;

  networking = {
    hostName = "drapion";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
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
