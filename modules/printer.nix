{ config, lib, pkgs, ... }:

let cfg = config.cookie.printing;
in with lib; {
  options.cookie.printing = {
    enable = mkEnableOption "Enables Printing Support";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
  };
}
