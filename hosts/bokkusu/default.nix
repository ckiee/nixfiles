{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ../.. ];

  cookie = {
    restic.enable = true; # Backups
    tailnet-certs.enableServer = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjcN4YgKxeaeQEERpYIwwZJXV3Hre4FfrD+cNi69Z6A";
      tailscaleIp = "100.124.234.25";
    };
    remote-builder.role = "user";
    wireguard = {
      ip = "10.67.75.1";
      endpoint = "bokkusu.ckie.dev";
    };
    services = {
      gitd.enable = true;
      minecraft.enable = true;
      mailserver.enable = true;
      among-sus.enable = true;
      anonvote-bot.enable = true;

      prometheus.enableServer = true;
      wikidict.enable = true;
      grafana = {
        enable = true;
        host = "grafana.ckie.dev";
      };
      rtc-files = {
        enable = true;
        # old-fqdn = ;
        new-fqdn = "ckie.dev";
      };
      ckiesite = {
        enable = true;
        host = "ckie.dev";
      };
      znc = {
        enable = true;
        host = "znc.ckie.dev";
        acmeHost = "ckie.dev"; # We use cookie.acme."ckie.dev".extras for this
      };
      # currently unused
      # soju = {
      #   enable = true;
      #   acmeHost = "ckie.dev"; # We use cookie.acme."ckie.dev".extras for this
      # };
      matrix = {
        enable = true;
        host = "ckie.dev";
        serviceHost = "matrix.ckie.dev";
      };
      mcid = {
        enable = true;
        host = "mcid.party";
      };
    };
    acme = {
      enable = true;
      hosts = {
        "ckie.dev" = {
          provider = "porkbun";
          extras = [
            "matrix.ckie.dev"
            "i.ckie.dev"
            "bokkusu.ckie.dev"
            "grafana.ckie.dev"
            "znc.ckie.dev"
            "dict.ckie.dev"
            "fedi.ckie.dev"
            "git.ckie.dev"
          ];
        };
        "tailnet.ckie.dev" = {
          wildcard = true;
          provider = "porkbun";
        };
        "mcid.party" = {
          provider = "cloudflare";
          secretId = "acme-dan";
        };
      };
    };
  };

  networking.hostName = "bokkusu";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
