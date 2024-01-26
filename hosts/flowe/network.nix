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
        "128.140.50.89/32"
        "2a01:4f8:c012:5bd3::1/64"
      ];
      networkConfig = {
        DHCP = "no"; # is default
        IPv6AcceptRA = "no";
      };
      routes = [
        # v6
        {
          routeConfig.Gateway = "fe80::1";
        }
        # v4
        { routeConfig.Destination = "172.31.1.1"; } # route is on interface
        { routeConfig.Gateway = "172.31.1.1"; } # use as gateway
      ];
    };
    # TODO: genericify out of host
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
