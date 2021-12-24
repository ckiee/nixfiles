{ sources, lib, config, pkgs, ... }:

with lib;
let
  pkgs-master = import sources.nixpkgs-master { };
  mail-util = pkgs.callPackage ./services/mailserver/util.nix { };

  cfg = config.cookie.acme;
  email = (builtins.head
    (mail-util.process (fileContents ../secrets/email-salt) [ "acme" ]));
  hosts = types.submodule {
    options = {
      provider = mkOption {
        type = types.str;
        description = "the DNS provider for this host";
        default = "cloudflare";
      };
      secretId = mkOption {
        type = types.str;
        description = "the secret containing the credentials for this provider";
        default = "acme";
      };
      extras = mkOption {
        type = types.listOf types.str;
        description = "a list of extra hosts to get in one cert";
        default = [ ];
      };
    };
  };
in {
  options.cookie.acme = {
    enable = mkEnableOption "Enables NGINX+ACME configuration";
    hosts = mkOption {
      type = types.attrsOf hosts;
      description = "hosts to provide certificates for";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = (mkMerge (mapAttrsToList (i: v:
      mkMerge (map (e: {
        ${e} = {
          forceSSL = true;
          useACMEHost = i;
        };
      }) ((v.extras or [ ]) ++ (singleton i)))) cfg.hosts));

    cookie.secrets = let
      mkAcme = file: {
        source = "./secrets/${file}";
        dest = "/var/run/${file}";
        owner = "acme";
        group = "acme";
        permissions = "0400";
      };
    in {
      acme = mkAcme "acme.env";
      acme-dan = mkAcme "acme-dan.env";
    };

    systemd.services = mapAttrs' (i: v:
      nameValuePair "acme-${i}" (rec {
        requires = [ "acme-key.service" ];
        after = requires;
      })) cfg.hosts;

    security.acme = {
      inherit email;
      acceptTerms = true;
      certs = (mapAttrs (i: v: ({
        group = "nginx";
        dnsProvider = v.provider;
        extraDomainNames = v.extras;
        credentialsFile = config.cookie.secrets.${v.secretId}.dest;
        inherit email;
      })) cfg.hosts);

    };
  };
}
