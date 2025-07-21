{ lib, config, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.services.coredns;
  sources = import ../../../nix/sources.nix;
  baseHosts = pkgs.runCommandLocal "coredns-hosts-ckie" {
    passAsFile = [ "extraHosts" ];
    extraHosts = cfg.extraHosts;
  } ''
    echo "# StevenBlack ad-blocking hosts" >> $out
    ${pkgs.ripgrep}/bin/rg -v " (click\.redditmail\.com|s\.click\.aliexpress\.com|shareasale\.com)$" ${sources.dns-hosts}/hosts \
        >> $out
    echo "# Extra hosts" >> $out
    cat $extraHostsPath >> $out
    echo "# Runtime hosts" >> $out
  '';
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
      default = "";
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

      # *coughs* ahemmm
      # (won't resolve over TLS)
      cookie.services.coredns.extraHosts = ''
        172.104.27.95 emma.coop
        172.104.27.95 blog.emma.coop
        ${concatMapStringsSep "\n" (s: "0.0.0.0 ${s}") [
          "x.com"
          "twitter.com"
          "bsky.app"
          "cnn.com"
          "tiktok.com"
        ]}
      '';

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

      # coredns is stopped early and started late in the script, so for now,
      # let's try to not restart it *at all*.
      #
      # TODO: it may also suffer from maybe-lacking systemd-notify (idk), but that's not as pressing
      systemd.services.coredns.restartIfChanged = false;

      services.coredns = {
        enable = true;

        config = let
          prom = if cfg.prometheus.enable then
            "prometheus FIXME:${toString cfg.prometheus.port}"
          else
            "";
          # we used to have "bind lo" in every block to work well w libvirtd but then it doesnt listen on the net iface
        in ''
          . {
            ${prom}
            hosts /run/coredns-hosts {
              reload 1500ms
              fallthrough
            }
            # We usually don't have IPv6 ):
            #rewrite stop type AAAA A
            forward . 127.0.0.1:5301
            errors
            cache 120 # two minutes
          }

          # Janky. Fucked up.
          # 1.1.1.1 Was unused for a while
          # Also https://gist.github.com/ardislu/b2f2b4b439c5da2f7ccb6bb42e7a8882
          .:5301 {
            forward . tls://1.1.1.1 tls://1.0.0.1 tls://2606:4700:4700::1111 tls://2606:4700:4700::1001 {
              tls_servername cloudflare-dns.com
            }
          }

          .:5302 {
            forward . tls://45.90.28.0 {
              tls_servername dns.nextdns.io
            }
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
      # without networkmanager using sysd-resolved internally, networking.search doesnt work
      # TODO put in nixpkgs
      networking.resolvconf.extraConfig = ''
        search_domains=${hostSuffix}
      '';
    })
  ]);
}
