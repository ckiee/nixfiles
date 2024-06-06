{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.avahi;

in with lib; {
  options.cookie.services.avahi = {
    enable = mkEnableOption "Enables Avahi service discovery";
  };

  config.services.avahi = mkIf cfg.enable {
    enable = true;
    nssmdns4 = true; # Since most mDNS responders only register IPv4 addresses, most users want to keep the IPv6 support disabled to avoid long timeouts.
    ipv6 = false; # Things break.
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
