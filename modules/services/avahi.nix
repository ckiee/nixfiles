{ lib, config, pkgs, ... }:

let cfg = config.cookie.avahi;

in with lib; {
  options.cookie.avahi = {
    enable = mkEnableOption "Enables Avahi service discovery";
  };

  config.services.avahi = mkIf cfg.enable {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
