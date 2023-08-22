{ lib, config, pkgs, nodes, ... }:

with lib;

let
  cfg = config.cookie.rkvm;
  password = fileContents ../secrets/rkvm-password;
in {
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
              } \
              -d ${config.networking.hostName} \
              -i ${config.cookie.state.tailscaleIp} \
              secrets/rkvm-{cert,key}.pem
          '';
        };

        cookie.secrets.rkvm-password = rec {
          source = "./secrets/rkvm-password";
          generateCommand = "mkRng > ${source}";
          runtime = false; # should never leave the deploying machine..
        };

        services.rkvm.server = {
          enable = true;
          settings = {
            inherit password;
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
            inherit password;
            certificate = ../secrets/rkvm-cert.pem;
            # NOTE: hardcoded
            # we don't depend on DNS because rkvm-client starts faster
            # than coredns and i don't wanna fix that race atm.
            server =
              "${nodes.thonkcookie.config.cookie.state.tailscaleIp}:5258";
          };
        };
      })
    ]))

  ];
}
