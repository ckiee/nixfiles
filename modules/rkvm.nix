{ lib, config, pkgs, ... }:

let cfg = config.cookie.rkvm;

in with lib; {
  options.cookie.rkvm = {
    enable = mkEnableOption "rkvm, a Virtual KVM switch for Linux machines";
    role = mkOption {
      type = types.nullOr (types.enum [ "tx" "rx" ]);
      default = null;
      description = "The role of this machine";
    };
  };

  config = mkMerge [
    { cookie.rkvm.enable = mkDefault (cfg.role != null); }

    (mkIf cfg.enable (mkMerge [
      (mkIf (cfg.role == "tx") {
        cookie.secrets.rkvm-key = {
          source = "./secrets/rkvm-key.pem";
          permissions = "0400";
          generateCommand = ''
            ${config.services.rkvm.package}/bin/rkvm-certificate-gen \
              -D ${ # 10 years
                "3650"
              } -d ${config.networking.hostName} \
              secrets/rkvm-{cert,key}.pem
          '';
        };

        services.rkvm.server = {
          enable = true;
          settings = {
            password = "meownya";
            key = config.cookie.secrets.rkvm-key.dest;
            certificate = ../secrets/rkvm-cert.pem;
          };
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5258 ];
      })

      (mkIf (cfg.role == "rx") {
        services.rkvm.client = {
          enable = true;
          settings = {
            password = "meownya";
            certificate = ../secrets/rkvm-cert.pem;
            # NOTE: hardcoded
            server = "thonkcookie:5258";
          };
        };
      })
    ]))

  ];
}
