{ lib, config, pkgs, ... }:

with lib;
let
  sources = import ../nix/sources.nix;
  pkgs-master = import sources.nixpkgs-master { };

  cfg = config.cookie.acme;
  email = "me@ronthecookie.me";
  hosts = types.submodule {
    options = {
      provider = mkOption {
        type = types.str;
        description = "the DNS provider for this host";
        default = "cloudflare";
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

    cookie.secrets.acme = {
      source = ../secrets/acme.env;
      dest = "/run/keys/acme.env";
      owner = "acme";
      group = "acme";
      permissions = "0400";
    };

    systemd.services = mapAttrs' (i: v:
      nameValuePair "acme-${i}" (rec {
        wants = [ "acme-key.service" ];
        after = wants;
      })) cfg.hosts;

    # Porkbun is only in lego 4.4.0 which is in master ATM.
    # TODO: remove this
    nixpkgs.overlays = [ (self: super: { inherit (pkgs-master) lego; }) ];

    security.acme = {
      inherit email;
      acceptTerms = true;
      certs = (mapAttrs (i: v: ({
        group = "nginx";
        dnsProvider = v.provider;
        extraDomainNames = v.extras;
        credentialsFile = config.cookie.secrets.acme.dest;
        inherit email;
      })) cfg.hosts);

    };
  };
}
