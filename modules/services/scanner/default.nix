{ lib, config, pkgs, ... }:

with lib;

let cfg = config.cookie.services.scanner;
in {
  options.cookie.services.scanner = {
    enable = mkEnableOption "Enables and configures SANE as the server";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      hardware.sane = {
        enable = true;
        # HP_LaserJet_M1536dnf_MFP
        extraBackends = [ config.cookie.services.printing.hplipPackage ];
      };
    })
  ];
}
