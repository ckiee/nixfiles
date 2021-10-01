{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.scanner;

in with lib; {
  options.cookie.services.scanner = {
    enableServer = mkEnableOption "Enables and configures SANE as the server";
    enableClient = mkEnableOption "Enables and configures SANE as the client";
  };

  config = mkMerge [
    {
      assertions = [{
        assertion = !(cfg.enableServer && cfg.enableClient);
        message = "the client and server cannot be enabled simultaneously.";
      }];
    }

    (mkIf cfg.enableServer {
      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.hplipWithPlugin ]; # HP Deskjet 2510
      };
      services.saned = {
        enable = true;
        openFirewall = true;
        extraConfig = "192.168.0.0/24"; # Share with LAN
      };
    })

    (mkIf cfg.enableClient {
      hardware.sane = {
        enable = true;
        netConf = "scan.atori"; # see /ext/atori.zone
      };
    })
  ];
}
