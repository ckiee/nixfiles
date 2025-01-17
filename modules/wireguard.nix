{ lib, config, pkgs, nodes, ... }:

with lib;

let
  cfg = config.cookie.wireguard;
  hostname = config.networking.hostName;
  forWgNode = f:
    (filter (x: x != null) (mapAttrsToList
      (_: h: if h.config.cookie.wireguard.enable then f h.config else null)
      nodes));
  ulaPrefix = "fd9b:ada7:dbaa";
in {
  options.cookie.wireguard = {
    enable = mkEnableOption "Enables wireguard cknet";
    num = mkOption {
      type = types.int;
      description = "the ip-suffix assigned to this peer";
      example = 13;
    };
    ipv4 = mkOption {
      type = types.str;
      description = "the ipv4 assigned to this peer";
      default = "10.67.75.${toString cfg.num}";
    };
    ipv6 = mkOption {
      type = types.str;
      description = "the ipv6 /64 assigned to this peer";
      default = "${ulaPrefix}:${toLower (toHexString cfg.num)}";
    };
    endpoint = mkOption {
      type = types.nullOr types.str;
      description = "an optional endpoint for this peer";
      example = "some-node.ckie.dev";
      default = null;
    };
    v6TunnelEndpoint = mkEnableOption "peer to be used as v6 tunnel endpoint";
  };

  config = mkMerge [

    (mkIf cfg.enable {
      cookie.secrets.wg-privkey = {
        source = "./secrets/wg-privkey-${hostname}";
        permissions = "0400";
        # wantedBy = "pleroma.service";
        generateCommand = ''
          wg genkey | tee secrets/'wg-privkey-${hostname}' | wg pubkey > secrets/'wg-pubkey-${hostname}'
        '';
      };

      networking = {
        firewall = {
          allowedUDPPorts = singleton 51820;
          allowedTCPPorts = singleton 51820;
        };
        wireguard = {
          useNetworkd = false;
          interfaces.cknet = {
            ips = [ "${cfg.ipv4}/32" "${cfg.ipv6}::1/64" ];
            listenPort = mkIf (cfg.endpoint != null) 51820;
            privateKeyFile = config.cookie.secrets.wg-privkey.dest;
          };
        };
      };

      networking.wireguard.interfaces.cknet.peers = forWgNode (hc:
        let hcfg = hc.cookie.wireguard;
        in {
          publicKey =
            fileContents (../secrets + "/wg-pubkey-${hc.networking.hostName}");
          allowedIPs = [ "${hcfg.ipv4}/32" "${hcfg.ipv6}::1/64" ];
          # TODO make it work
          # ++ optional (hcfg.v6TunnelEndpoint && !cfg.v6TunnelEndpoint) "::/0"
          # ++ optional (hc.networking.hostName == "cookiemonster")
          # "2a05:f480:2c00:19ee:8003::/80";
          persistentKeepalive = 1;
          endpoint =
            if hcfg.endpoint != null then "${hcfg.endpoint}:51820" else null;
          # endpointsUpdater.enable = hcfg.endpoint != null;
        });

      networking.extraHosts = concatStringsSep "\n" (forWgNode (hc:
        concatMapStringsSep "\n"
        (addr: "${addr} ${hc.networking.hostName}.cknet") [
          hc.cookie.wireguard.ipv4
          "${hc.cookie.wireguard.ipv6}::1"
        ]));
    })
  ];

}
