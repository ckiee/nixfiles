{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.acme;
  email = "me@ronthecookie.me";
in with lib; {
  options.cookie.acme = {
    enable = mkEnableOption "Enables NGINX ACME configuration";
    hosts = mkOption rec {
      type = types.listOf types.str;
      description = "List of hosts to setup ACME/SSL for";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = mkMerge (imap0 (i: v: ({
      "${v}" = {
        forceSSL = true;
        useACMEHost = v;
      };
    })) cfg.hosts);

    cookie.secrets.acme-cloudflare = {
      source = ../secrets/cloudflare.env;
      dest = "/var/run/acme-cloudflare.env";
      owner = "acme";
      group = "acme";
      permissions = "0400";
    };

    security.acme = {
      inherit email;
      acceptTerms = true;
      certs = mkMerge (imap0 (i: v: ({
        "${v}" = {
          group = "nginx";
          dnsProvider = "cloudflare";
          credentialsFile = "/var/run/acme-cloudflare.env";
          inherit email;
        };
      })) cfg.hosts);

    };
  };
}
