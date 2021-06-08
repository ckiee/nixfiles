{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.avahi;

in with lib; {
  options.cookie.services.avahi = {
    enable = mkEnableOption "Enables Avahi service discovery";
  };

  config.services.avahi = mkIf cfg.enable {
    enable = true;
    nssmdns = true;
    ipv6 = false; # Things break.
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
