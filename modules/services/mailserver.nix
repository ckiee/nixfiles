{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.mailserver;
  sources = import ../../nix/sources.nix;
in with lib; {
  imports = [ (import sources.nixos-mailserver) ];

  options.cookie.services.mailserver = {
    enable = mkEnableOption "Enables the mailserver module";
  };

  config = mkIf cfg.enable {
    cookie.secrets.mailserver-pw-hash = {
      source = ../../secrets/mailserver-pw-hash;
      dest = "/run/keys/mailserver-pw-hash";
      owner = "root";
      group = "root";
      permissions = "0400";
    };

    mailserver = {
      enable = true;
      fqdn = "bokkusu.ckie.dev";
      domains = [ "ckie.dev" ];
      certificateScheme = 1; # Manually specify certificate paths

      certificateFile = "/var/lib/acme/ckie.dev/cert.pem";
      keyFile = "/var/lib/acme/ckie.dev/key.pem";

      loginAccounts = {
        "us@ckie.dev" = {
          hashedPasswordFile = config.cookie.secrets.mailserver-pw-hash.dest;
          aliases = [ "postmaster@ckie.dev" ];
        };
      };
    };
  };

}
