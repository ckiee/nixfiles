{ config, lib, pkgs, ... }:

let cfg = config.cookie.services.printing;
in with lib; {
  options.cookie.services.printing = {
    enable = mkEnableOption "Enables Printing Support";
    server = mkEnableOption "Configures this CUPS instance to be the server";
    host = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "host for the web interface";
    };
    hplipPackage = mkOption {
      default = pkgs.hplipWithPlugin.override { withQt5 = false; };
      readOnly = true;
      description = "the hplip driver package";
    };
  };

  config = mkMerge [
    # Common
    (mkIf cfg.enable {
      services.printing = {
        enable = true;
        drivers = [ cfg.hplipPackage ];
      };
    })
    # Server-only
    (mkIf (cfg.enable && cfg.server) {
      assertions = [{
        assertion = cfg.host != null;
        message = "cookie.services.printing.host must be non-nil";
      }];

      hardware.printers = let name = "Deskjet_2510";
      in {
        ensureDefaultPrinter = name;
        ensurePrinters = [{
          inherit name;
          description = "the evil Printer~~";
          deviceUri =
            "usb://HP/Deskjet%202510%20series?serial=CN26J22HJ805TX&interface=1";
          model = "raw";
        }];
      };

      services.printing = {
        browsing = true; # Probably mDNS for printers
        defaultShared = true;
        logLevel = "debug";
      };

      cookie.services.nginx.enable = true; # firewall & recommended defaults
      services.nginx.virtualHosts.${cfg.host} = {
        locations."/" = {
          proxyPass = "http://[::1]:631";
          recommendedProxySettings = false;
        };
      };
    })
    # Client-only
    (mkIf (cfg.enable && !cfg.server) {
      hardware.printers = let name = "Deskjet_2510";
      in {
        ensureDefaultPrinter = name;
        ensurePrinters = [{
          inherit name;
          description = "the evil Printer~~";
          deviceUri = "http://print.atori/printers/${name}";
          model = "drv:///hp/hpcups.drv/hp-deskjet_2510_series.ppd";
          ppdOptions = {
            PageSize = "A4";
            InputSlot = "Auto";
            ColorModel = "KGray";
            MediaType = "Plain";
            OutputMode = "Normal";
          };
        }];
      };
    })
  ];
}
