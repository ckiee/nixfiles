{ lib, config, pkgs, nodes, ... }:

with lib;

let
  cfg = config.cookie.wireguard;
  hostname = config.networking.hostName;
in {
  options.cookie.wireguard = {
    enable = mkEnableOption "Enables wireguard cknet";
    ip = mkOption {
      type = types.str;
      description = "the ip assigned to this peer";
      example = "10.67.75.13";
      default = "haah";
    };
    endpoint = mkOption {
      type = types.nullOr types.str;
      description = "an optional endpoint for this peer";
      example = "some-node.ckie.dev";
      default = null;
    };
  };

  config = mkMerge [
    {
      cookie.wireguard.ip = let
        withIndices =
          imap1 (i: x: { i = i; x = nodes.${x}; }) (attrNames nodes);
        thisNode = findFirst
          (cmp: cmp.x.config.networking.hostName == config.networking.hostName)
          null withIndices;
      in (mkDefault "10.67.75.${toString (1 + thisNode.i)}");
    }

    (mkIf cfg.enable {
      cookie.secrets."wg-privkey-${hostname}" = {
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
          allowedTCPPorts = singleton
            51820; # really this is only needed for the cknet interface but /shrug systemd should filter it out anyway
        };
        wireguard.interfaces.cknet = {
          ips = singleton cfg.ip;
          listenPort = 51820;
          privateKeyFile = config.cookie.secrets."wg-privkey-${hostname}".dest;
          peersAnnouncing.enable = cfg.endpoint != null;
        };
      };

      networking.wireguard.interfaces.cknet = {
        peers = (filter (x: x != null) (mapAttrsToList (_: h:
          if h.config.cookie.wireguard.enable then
            let hcfg = h.config.cookie.wireguard;
            in {
              publicKey = fileContents
                (../secrets + "/wg-pubkey-${h.config.networking.hostName}");
              allowedIPs = singleton "${hcfg.ip}/32";
              persistentKeepalive = 1;
              endpoint = if hcfg.endpoint != null then
                "${hcfg.endpoint}:51820"
              else
                null;
              endpointsUpdater.enable = hcfg.endpoint != null;
            }
          else
            null) nodes));

      };
    })
  ];

}
