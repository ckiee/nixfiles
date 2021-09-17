{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.mailserver;
  sources = import ../../../nix/sources.nix;
  util = pkgs.callPackage ./util.nix { };
in with lib;
with builtins; {
  imports = [ (import sources.nixos-mailserver) ];

  options.cookie.services.mailserver = {
    enable = mkEnableOption "Enables the mailserver module";
    aliases = mkOption rec {
      type = types.listOf types.str;
      description = "Base e-mail aliases to be processed";
      default = util.default-aliases;
    };
    certFqdn = mkOption {
      type = types.str;
      description = "The FQDN of the certificate we should piggyback off of";
      default = "ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.secrets.mailserver-pw-hash = {
      source = "./secrets/mailserver-pw-hash";
      dest = "/run/keys/mailserver-pw-hash";
      owner = "root";
      group = "root";
      permissions = "0400";
    };
    cookie.secrets.email-salt = {
      source = "./secrets/email-salt";
      runtime = false;
    };

    # Restart dovecot2 when we get new certificates: before doing this my cert
    # actually expired and broke stuff because dovecot had been running for so long.
    security.acme.certs.${cfg.certFqdn}.postRun = "systemctl restart dovecot2";

    mailserver = {
      enable = true;
      fqdn = "bokkusu.ckie.dev";
      domains = [ "ckie.dev" ];
      certificateScheme = 1; # Manually specify certificate paths

      certificateFile = "/var/lib/acme/${cfg.certFqdn}/cert.pem";
      keyFile = "/var/lib/acme/${cfg.certFqdn}/key.pem";

      loginAccounts = {
        "us@ckie.dev" = {
          hashedPasswordFile = config.cookie.secrets.mailserver-pw-hash.dest;
          aliases = [ "postmaster@ckie.dev" ]
            ++ (util.process (fileContents ../../../secrets/email-salt)
              cfg.aliases);
        };
      };
    };
  };

}
