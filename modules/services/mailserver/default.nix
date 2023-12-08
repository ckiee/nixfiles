{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.mailserver;
  util = pkgs.callPackage ./util.nix { };
  sources = import ../../../nix/sources.nix;
in with lib;
with builtins; {
  imports = [ (import sources.nixos-mailserver) ];

  options.cookie.services.mailserver = {
    enable = mkEnableOption "mailserver module";
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
    cookie.secrets = rec {
      # TODO: dedup
      mailserver-pw-hash = {
        source = "./secrets/mailserver-pw-hash";
        dest = "/run/keys/mailserver-pw-hash";
        owner = "root";
        group = "root";
        permissions = "0400";
      };

      mailserver-dkim-priv = {
        source = "./secrets/dkim.mail.key";
        dest = "/var/dkim/ckie.dev.mail.key";
        owner = "opendkim";
        group = "opendkim";
        permissions = "0400";
      };
      mailserver-dkim-pub = {
        source = "./secrets/dkim.mail.txt";
        dest = "/var/dkim/ckie.dev.mail.txt";
        inherit (mailserver-dkim-priv) owner group permissions;
      };
    };

    # Restart dovecot2 when we get new certificates: before doing this my cert
    # actually expired and broke stuff because dovecot had been running for so long.
    security.acme.certs.${cfg.certFqdn}.postRun = "systemctl restart dovecot2";

    cookie.restic.paths = [ config.mailserver.mailDirectory ];

    # there's a postfix-setup unit and for annoying reasons it misses it, grep our first
    # tildechat #helpdesk convo for story.
    systemd.services.postfix.serviceConfig."X-Stupid-Hack-${
      builtins.hashString "sha256" (concatStringsSep "\n" cfg.aliases)
    }" = true;

    mailserver = {
      enable = true;
      localDnsResolver = false; # :53 needs to be open for services/coredns
      fqdn = "bokkusu.ckie.dev";
      domains = [ "ckie.dev" ];

      certificateScheme = "manual"; # Manually specify certificate paths
      certificateFile = "/var/lib/acme/${cfg.certFqdn}/cert.pem";
      keyFile = "/var/lib/acme/${cfg.certFqdn}/key.pem";

      messageSizeLimit = 31457280; # 30 MiB, needs to account for base64'd attachments I think, stackoverflow says base64'd makes contents 4*(old_bytes/3) bytes big

      loginAccounts = {
        "us@ckie.dev" = {
          hashedPasswordFile = config.cookie.secrets.mailserver-pw-hash.dest;
          aliases = [ "postmaster@ckie.dev" "work-sbr@ckie.dev" "mei@ckie.dev" ]
            ++ (util.process (fileContents ../../../secrets/email-salt)
              cfg.aliases);
          quota = "5G";
        };
      };
    };
  };

}
