# hey! are you here to debug this?
#     Jul 14 18:53:31 pansear nginx[1338328]: 2023/07/14 18:53:31
#     [crit] 1338328#1338328: *4166 open() "/tmp/nginx_client_body/0000000014" failed (2: No such file or directory), client: 192.168.0.29, server: print.atori, request: "POST /printers/RawDeskjet HTTP/1.1", host: "print.atori"
# if so, go here:
#     https://matrix.to/#/!KqkRjyTEzAGRiZFBYT:nixos.org/$hQsxz760br1mmnf9GlINF0c6OdWTd37y-cgXY4k9bho?via=nixos.org&via=matrix.org&via=tchncs.de
# 2023-08-03 update:
#     https://matrix.to/#/!KqkRjyTEzAGRiZFBYT:nixos.org/~!KqkRjyTEzAGRiZFBYT:nixos.org:m1691073056899.57?via=nixos.org&via=matrix.org&via=tchncs.de
#
{ config, lib, pkgs, ... }:

let
  cfg = config.cookie.services.printing;
  rawName = "RawDeskjet";
  drvDeskjet = "DrvDeskjet";
  ppd = "drv:///hp/hpcups.drv/hp-deskjet_2510_series.ppd";
  raw = "raw";
in with lib; {
  options.cookie.services.printing = {
    enable = mkEnableOption "Enables Printing Support";
    server = mkEnableOption "Configures this CUPS instance to be the server";
    host = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "host for the web interface";
    };
    tlsHost = mkOption {
      type = types.str;
      default = "print-unreal.tailnet.ckie.dev";
      readOnly = true;
      description = "janky TLS host for the web interface";
    };
    hplipPackage = mkOption {
      default = pkgs.hplipWithPlugin.override { withQt5 = false; };
      readOnly = true;
      description = "the hplip driver package";
    };
  };

  config = mkMerge [
    # Global (we're assuming this is enabled on atleast one host)
    {
      # HACK-ity hack, pansear is .8 on LAN, this whole tlsHost junk is just for android compat
      cookie.services.coredns.extraHosts = "192.168.0.8 ${cfg.tlsHost}";
    }
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

      hardware.printers = {
        ensureDefaultPrinter = rawName;
        ensurePrinters = [{
          name = rawName;
          description = "the evil Printer, but raw~~";
          deviceUri =
            "usb://HP/Deskjet%202510%20series?serial=CN26J22HJ805TX&interface=1";
          model = raw;
        }];
      };

      services.printing = {
        browsing = true; # Probably mDNS for printers
        defaultShared = true;
        # logLevel = "debug";
      };

      cookie.services.nginx.enable = true; # firewall & recommended defaults
      services.nginx.virtualHosts = let
        common = {
          proxyPass = "http://[::1]:631";
          recommendedProxySettings = false;
          extraConfig = ''
            # Aug 03 15:35:26 pansear nginx[2036676]: 2023/08/03 15:35:26 [crit] 2036676#2036676: *3502 open() "/tmp/nginx_client_body/0000000025" failed (2: No such file or directory), client: 192.168.0.142, server: print.atori, request: "POST /printers/RawDeskjet HTTP/1.1", host: "print.atori:80"
            # XXX: Attempt to workaround this by disabling some buffering things. Hopefully includes this nginx_client_body buffering.
            # https://serverfault.com/a/733742
            proxy_request_buffering off;
            proxy_http_version 1.1;
            client_max_body_size 0;
          '';
        };
      in {
        ${cfg.host} = { locations."/" = common; };
        ${cfg.tlsHost} = { locations."/" = common; };
      };
    })
    (mkIf cfg.enable {
      hardware.printers = {
        ensureDefaultPrinter = mkIf (!cfg.server) drvDeskjet;
        ensurePrinters = [{
          name = drvDeskjet;
          description = "the evil Printer~~";
          deviceUri = if cfg.server then
            "http://[::1]:631/printers/${rawName}"
          else
            "http://print.atori/printers/${rawName}";
          model = ppd;
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
