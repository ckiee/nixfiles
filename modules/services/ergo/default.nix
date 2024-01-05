{ lib, config, pkgs, ... }:
with lib;
let cfg = config.cookie.services.ergo;

in {
  options.cookie.services.ergo = {
    enable = mkEnableOption "Ergo IRC service";

    fqdn = mkOption {
      type = types.str;
      default = "puppycat.house";
      description = "Full host to share";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.enable -> !config.cookie.services.znc.enable;
      message = "blabl lbla no ergo + znc. xor.";
    }];

    networking.firewall.allowedTCPPorts = [ 6697 ];

    systemd.services.ergochat.serviceConfig = {
      LoadCredential = [
        "fullchain.pem:/var/lib/acme/${cfg.fqdn}/fullchain.pem"
        "key.pem:/var/lib/acme/${cfg.fqdn}/key.pem"
      ];
    };

    services.ergochat = {
      enable = true;
      # https://raw.githubusercontent.com/ergochat/ergo/0f059ea2cc98fb0a846d7701cf5dc21f060d931c/default.yaml
      settings = {
        accounts = {
          multiclient = {
            enable = true;
            allowed-by-default = true;
          };
          nick-reservation.force-nick-equals-account = false;
          vhosts = {
            enabled = true;
            max-length = 64;
            valid-regexp = "^[0-9A-Za-z.\-_/]+$";
          };
        };

        logging = [{
          level = "debug";
          type = "* -userinput -useroutput";
          method = "stderr";
        }];

        network.name = "puppycat.house";

        server = {
          listeners = {
            ":6667" = { sts-only = true; };

            ":6697" = {
              tls = {
                # $CREDENTIALS_DIRECTORY, but instead using the non-public API cause I don't
                # think we have variable subst in here (haven't tried)
                cert = "/run/credentials/ergochat.service/fullchain.pem";
                key = "/run/credentials/ergochat.service/key.pem";
              };

              min-tls-version = 1.2;
            };
          };

          sts = {
            enabled = true;
            # how long clients should be forced to use TLS for.
            duration = "1mo2d5m";
          };

          name = cfg.fqdn;
          motd = pkgs.writeText "ergo.motd" "TODO: Welcome back!";

          ip-cloaking = {
            enabled = true;
            netname = "house";
            num-bits = 0;
          };
        };

        opers = {
          ckie = {
            class = "server-admin";
            certfp =
              "7555d626abdc49b19d7d8629c4921dd85564cfaa2fbe3d139c59bd3b87546750";
            auto = true;
          };
          admin = {
            class = "server-admin";
            password =
              "$2a$04$0x.qR7guLXkoxPpsCDVNfuyaWEXizU435upNmzYq1BOIwOjZm8k5i";
          };
        };


        oper-classes = {
          # chat moderator: can ban/unban users from the server, join channels,
          # fix mode issues and sort out vhosts.
          "chat-moderator" = {
            # title shown in WHOIS
            title = "Chat Moderator";

            # capability names
            capabilities = [
              "kill" # disconnect user sessions
              "ban" # ban IPs, CIDRs, NUH masks, and suspend accounts (UBAN / DLINE / KLINE)
              "nofakelag" # exempted from "fakelag" restrictions on rate of message sending
              "relaymsg" # use RELAYMSG in any channel (see the `relaymsg` config block)
              "vhosts" # add and remove vhosts from users
              "sajoin" # join arbitrary channels, including private channels
              "samode" # modify arbitrary channel and user modes
              "snomasks" # subscribe to arbitrary server notice masks
              "roleplay" # use the (deprecated) roleplay commands in any channel
            ];
          };
          # server admin: has full control of the ircd, including nickname and
          # channel registrations
          "server-admin" = {
            # title shown in WHOIS
            title = "Server Admin";

            # oper class this extends from
            extends = "chat-moderator";

            # capability names
            capabilities = [
              "rehash" # rehash the server, i.e. reload the config at runtime
              "accreg" # modify arbitrary account registrations
              "chanreg" # modify arbitrary channel registrations
              "history" # modify or delete history messages
              "defcon" # use the DEFCON command (restrict server capabilities)
              "massmessage" # message all users on the server
            ];
          };
        };
      };
    };
  };
}
