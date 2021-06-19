{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.mail-client;
  maildir = "${config.home.homeDirectory}/Mail";
in with lib; {
  options.cookie.mail-client = {
    enable = mkEnableOption "Enables the mail client";
  };

  config = mkIf cfg.enable {
    accounts.email = {
      maildirBasePath = "${maildir}";
      accounts = {
        ckiedev = rec {
          flavor = "plain"; # A better name for this option would be "quirks", it is set to plain because we are not doing anything odd.
          address = "us@ckie.dev";
          userName = address;
          aliases = [ address ];
          passwordCommand = "${pkgs.coreutils}/bin/cat ~/Sync/.email-pw-ckiedev";
          realName = "${name}";
          primary = true;
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            patterns = [ "*" ];
          };
          imap = {
            host = "ckie.dev";
            port = 993;
            tls.enable = true;
          };
          msmtp.enable = true;
          smtp = {
            host = "ckie.dev";
            port = 587;
            tls.useStartTls = true;
          };
        };
      };
    };

    programs = {
      msmtp.enable = true;
      mbsync.enable = true;
    };

    services = {
      mbsync = {
        enable = true;
        frequency = "*:0/15";
        preExec = "${pkgs.isync}/bin/mbsync -Ha";
        postExec = "${pkgs.mu}/bin/mu index -m ${maildir}";
      };
    };
  };
}
