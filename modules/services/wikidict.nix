{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.wikidict;
  mail-util = pkgs.callPackage ./mailserver/util.nix { };
in with lib; {
  options.cookie.services.wikidict = {
    enable = mkEnableOption "Enables wikidict, a MediaWiki instance";
    email = mkOption rec {
      type = types.str;
      default = (builtins.head
        (mail-util.process (fileContents ../../secrets/email-salt) [ "git" ]));
      description = "Admin email to use";
      example = default;
    };
    host = mkOption {
      type = types.str;
      default = "dict.ckie.dev";
      description = "Mediawiki host";
    };
  };

  config = mkIf cfg.enable {
    cookie.secrets.wikidict-admin-pw = {
      source = "./secrets/wikidict_admin_pw";
      dest = "/var/lib/containers/wikidict/aaa/pw";
      permissions = "0400";
      group = toString config.ids.gids.wwwrun;
      wantedBy = "container@wikidict.service";
    };
    systemd.services.wikidict-admin-pw-key.preStart =
      mkMerge [ (mkBefore "mkdir -p /var/lib/containers/wikidict/aaa") ];

    cookie.services.nginx.enable = true;
    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { proxyPass = "http://wikidict.containers"; };
        extraConfig = ''
          access_log /var/log/nginx/wikidict.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "wikidict" ];

    boot.enableContainers = true;
    containers.wikidict = {
      autoStart = true;
      privateNetwork = true;

      hostAddress = "192.168.77.86";
      localAddress = "192.168.77.87"; # MW ascii

      forwardPorts = [{
        containerPort = 80;
        hostPort = 34539;
        protocol = "tcp";
      }];

      bindMounts = { "/dev/fuse" = { hostPath = "/dev/fuse"; }; };

      allowedDevices = [{
        modifier = "rwm";
        node = "/dev/fuse";
      }];

      config = let hostConfig = config;
      in { config, ... }: {
        imports = [ ../.. ];
        networking.networkmanager.enable = mkForce false;
        networking.firewall.enable = false;

        cookie = {
          services = {
            ssh.enable = mkForce false;
            tailscale.enable = false;
            coredns.enable = mkForce false;
          };
          git.enable = mkForce false;
          ipban.enable = mkForce false;
          shell-utils.enable = mkForce false;

          bindfs.pwfile = {
            source = "/aaa";
            overlay = true;
            args = "-M mediawiki --chmod-ignore -p u=rwD";
          };
        };

        services.mediawiki = {
          enable = true;
          name = "WikiDict";
          passwordFile = "/aaa/pw";
          virtualHost = {
            hostName = cfg.host;
            adminAddr = cfg.email;
          };
        };
      };
    };
  };
}
