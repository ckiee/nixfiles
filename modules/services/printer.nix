{ config, lib, pkgs, ... }:

let
  cfg = config.cookie.services.printing;
  # ppd = "drv:///hp/hpcups.drv/hp-deskjet_2510_series.ppd";
in with lib; {
  options.cookie.services.printing = {
    enable = mkEnableOption "Enables Printing Support";
    parentsServer = mkEnableOption "Configures this CUPS instance to be the parentsServer";
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

    (mkIf cfg.enable {
      hardware.printers = {
        ensurePrinters = [{
          name = "laserjet";
          description = "big box printy print";
          deviceUri = "dnssd://HP%20LaserJet%20M1536dnf%20MFP%20(3F3DF3)._ipp._tcp.local/?uuid=434e4339-4333-4a42-3550-984be13f3df3";
          model = "drv:///hp/hpcups.drv/hp-laserjet_m1530_mfp_series-ps.ppd";
          ppdOptions = {
            PageSize = "A4";
            InputSlot = "Auto";
          };
        }];
      };
    })

    # parents
    (mkIf (cfg.enable && cfg.parentsServer) {
      assertions = [{
        assertion = cfg.host != null;
        message = "cookie.services.printing.host must be non-nil";
      }];

      hardware.printers = {
        ensureDefaultPrinter = "RawDeskjet";
        ensurePrinters = [{
          name = "RawDeskjet";
          description = "the evil Printer, but raw~~";
          deviceUri =
            "usb://HP/Deskjet%202510%20series?serial=CN26J22HJ805TX&interface=1";
          model = "raw";
        }];
      };

      services.printing = {
        browsing = true; # Probably mDNS for printers
        defaultShared = true;
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ]; # EHHHH?
        # logLevel = "debug";
      };

      # the NetPrint android app resolves dns and passes in Host: <ip> instead of the original host..
      networking.firewall.allowedTCPPorts = [ 631 ];

      cookie.services.nginx.enable = true; # firewall & recommended defaults
      services.nginx.virtualHosts = let
        common = {
          proxyPass = "http://[::1]:631";
          recommendedProxySettings = false;
          extraConfig = ''
            # Aug 03 15:35:26 pansear nginx[2036676]: 2023/08/03 15:35:26 [crit] 2036676#2036676: *3502 open() "/tmp/nginx_client_body/0000000025" failed (2: No such file or directory), client: 192.168.0.142, parentsServer: print.atori, request: "POST /printers/RawDeskjet HTTP/1.1", host: "print.atori:80"
            # XXX: Attempt to workaround this by disabling some buffering things. Hopefully includes this nginx_client_body buffering.
            # https://parentsServerfault.com/a/733742
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
  ];
}
