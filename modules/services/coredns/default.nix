{ lib, config, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.services.coredns;
  sources = import ../../../nix/sources.nix;
  extHostsRaw = builtins.readFile "${sources.dns-hosts}/hosts";
  extHosts = (concatStringsSep "\n" (filter (x:
    !(elem x [
      # exemptions from the block lists
      "0.0.0.0 click.redditmail.com"
    ])) (splitString "\n" extHostsRaw)));
  baseHosts = pkgs.writeTextFile {
    name = "coredns-hosts-ckie";
    text = ''
      # StevenBlack ad-blocking hosts
      ${extHosts}
      # Extra hosts
      ${cfg.extraHosts}
      # Runtime hosts
    '';
  };
  hostSuffix = ".tailnet.ckie.dev";
in {
  options.cookie.services.coredns = {
    enable = mkEnableOption "Enables CoreDNS service";
    useLocally = mkEnableOption "Use this as the system DNS resolver";
    openFirewall = mkEnableOption "Open the listening port in the firewall";
    prometheus = {
      enable = mkEnableOption "Add prometheus monitoring";
      port = mkOption {
        type = types.port;
        description = "The port to listen for requests from Prometheus";
        default = 47824;
      };
    };
    extraHosts = mkOption {
      type = types.lines;
      description = "Extra hosts separated by lines";
    };
  };

  # Okay so, on my home network the router is configured to force all :53 traffic to drapion.atori:53
  # This means that even when this service is running ON drapion, it cannot
  # dial up unencrypted DNS servers.
  #
  # So instead, we run:
  # - dnscrypt=proxy2:      proxying raw DNS to DNS-over-HTTPS
  # - dns-hosts-poller: creating /run/coredns-hosts with ad-servers to block AND tailscale hosts.
  # - coredns:          tying it all together and caching a bit
  #
  # This allows for (relative) privacy while also letting us use `galaxy-a51.tailnet.ckie.dev`
  # instead of the IP.
  #
  # p.s. we also configure magic so we can drop the `.tailnet.ckie.dev` part. Just `galaxy-a51`
  config = mkIf cfg.enable (mkMerge [
    {
      # dnscrypt is quite clever and will measure latency to many
      # servers until it can find the one with the lowest latency.
      services.dnscrypt-proxy2 = {
        enable = true;
        settings = { listen_addresses = [ "127.0.0.1:1483" ]; };
      };

      systemd.services.dns-hosts-poller = {
        description =
          "Update the /run/coredns-hosts hosts file with new Tailscale hosts";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = pkgs.runCommandLocal "dns-hosts-poller" {
            inherit (pkgs) bash tailscale jq;
            inherit baseHosts hostSuffix;
          } ''
            substituteAll "${./dns-hosts-poller}" "$out"
            chmod +x "$out"
          '';
        };

        preStart = ''
          rm /run/coredns-hosts || true
          ln -s ${baseHosts} /run/coredns-hosts
        '';
      };

      systemd.services.coredns = {
        requires = [ "dnscrypt-proxy2.service" ];
        after = [ "dnscrypt-proxy2.service" ];
      };

      services.coredns = {
        enable = true;

        config = let
          prom = if cfg.prometheus.enable then
            "prometheus FIXME:${toString cfg.prometheus.port}"
          else
            "";
        in ''
          . {
            ${prom}
            hosts /run/coredns-hosts {
              reload 1500ms
              fallthrough
            }
            forward . 127.0.0.1:1483
            errors
            cache 120 # two minutes
          }

          atori {
             ${prom}
             file ${./atori.zone}
          }

          # Resolve everything under the root localhost TLD to 127.0.0.1
          localhost {
            ${prom}
            template IN A  {
                answer "{{ .Name }} 0 IN A 127.0.0.1"
            }
          }
        '';
      };

    }
    (mkIf (cfg.openFirewall) {
      networking.firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    })
    (mkIf (cfg.useLocally) {
      # NetworkManager commits terrible crimes (i.e. listening on :53)
      networking.networkmanager.dns = "none";
      networking.resolvconf = {
        enable = true;
        useLocalResolver = true;
      };
      networking.search = singleton hostSuffix;
    })
  ]);
}
