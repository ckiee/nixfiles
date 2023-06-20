{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.mail-client;
  maildir = "${config.cookie.user.home}/Mail";
in with lib; {
  options.cookie.mail-client = {
    enable = mkEnableOption "Enables the mail client";
  };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { pkgs, ... }: {
      programs.thunderbird = {
        enable = true; # experimenting, tho we usually use mu4e.
        profiles.ckie.isDefault = true;
      };

      accounts.email = {
        maildirBasePath = maildir;
        accounts = let
          base = {
            mbsync = {
              enable = true;
              create = "both";
              expunge = "both";
              patterns = [ "*" ];
            };
            msmtp.enable = true;
          };
        in {
          # Self hosted, online
          ckiedev = mkMerge [
            base
            (rec {
              flavor =
                "plain"; # A better name for this option would be "quirks", it is set to plain because we are not doing anything odd.
              address = "us@ckie.dev";
              userName = address;
              aliases = [ address ];
              passwordCommand =
                "${pkgs.coreutils}/bin/cat ~/Sync/.email-pw-ckiedev";
              realName = "ckie";
              primary = true;
              smtp = {
                host = "ckie.dev";
                # https://nostarttls.secvuln.info
                port = 465;
                tls.enable = true;
              };
              imap = {
                host = "ckie.dev";
                port = 993;
                tls.enable = true;
              };
              thunderbird = {
                enable = true;
                profiles = [ "ckie" ];
              };
            })
          ];
          # IRL gmail
          irlgmail = mkMerge [ base ((import ../secrets/irlgmail.nix) pkgs) ];
        };
      };

      programs = {
        msmtp.enable = true;
        mbsync.enable = true;
      };

      systemd.user.services.mu4e-sync = {
        Unit = { Description = "mu4e-sync mailbox synchronization"; };

        Service = {
          Type = "oneshot";
          ExecStart = ''
            ${config.cookie.doom-emacs.package}/bin/emacsclient --eval "(mu4e-update-mail-and-index 'true)"'';
        };
      };

      systemd.user.timers.mu4e-sync = {
        Unit = { Description = "mu4e-sync mailbox synchronization"; };

        Timer = {
          OnCalendar = "*:0/15";
          Unit = "mu4e-sync.service";
        };

        Install = { WantedBy = [ "timers.target" ]; };
      };
    };
  };
}
