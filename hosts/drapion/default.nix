{ config, pkgs, lib, ... }:

with lib;

# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/drapion/default.nix --argstr system aarch64-linux
# build=$(nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=hosts/drapion/default.nix --argstr system aarch64-linux) && echo $build && nix copy --to ssh://drapion.local $build
# ^ The above does not work with generations for some reason. TODO Add to morph ^
{
  imports =
    [ ../.. <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix> ];

  cookie = {
    wol.enable = true;
    services = {
      avahi.enable = true;
      isp-troll.enable = true;
      scanner.enableServer = true;
      coredns = {
        enable = true;
        openFirewall = true;
        addServer = true;
      };
      printing = {
        enable = true;
        server = true;
        host = "print.atori";
      };
    };
  };

  networking.networkmanager.enable = mkForce false;

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