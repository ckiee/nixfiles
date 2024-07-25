{ config, lib, pkgs, ... }:

with lib;

{
  networking.networkmanager.enable = mkForce false;
  networking.useDHCP = mkForce false;
  services.resolved.enable = false; # systemd does not get to manage our DNS.
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."40-eth0" = {
      matchConfig.Name = "e*"; # eth0, eno0, or sometimes 1?
      addresses = map (addr: { addressConfig.Address = addr; }) [
        "64.176.168.188/23"
        "2a05:f480:2c00:19ee::1/64"
      ];
      networkConfig = {
        DHCP = "no"; # is default
        IPv6AcceptRA = "yes";
      };
      routes = [
        # v4
        { routeConfig.Destination = "64.176.168.1"; } # route is on interface
        { routeConfig.Gateway = "64.176.168.1"; } # use as gateway
      ];
    };
    # TODO: genericify out of host, originally in flowe
    networks."30-unmanaged-ts" = {
      matchConfig.Name = "tailscale*";
      linkConfig.Unmanaged = true;
    };
    networks."30-unmanaged-cknet" = {
      matchConfig.Name = "cknet";
      linkConfig.Unmanaged = true;
    };
  };

  boot.initrd.systemd.network.networks."40-eth0" =
    config.systemd.network.networks."40-eth0";

}
