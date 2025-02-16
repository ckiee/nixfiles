{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.vmware-host;

in with lib; {
  options.cookie.services.vmware-host = {
    enable = mkEnableOption "the VMWare host service";
  };

  config = mkIf cfg.enable {
    virtualisation.vmware.host = {
      enable = true;
    };
  };
}
