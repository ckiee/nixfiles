{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ./network.nix ../.. ];
  networking.hostName = "flowe";

  cookie = {
    restic.enable = true; # Backups
    systemd-initrd.enable = true;
    tailnet-certs.enableServer = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKS46DUbCbtBGhB+dx1/B/tegqI7i6ir1ofbTmTI+yYm root@flowe";
      tailscaleIp = "100.115.167.26";
    };
    wireguard = { endpoint = "flowe.ckie.dev"; };
    services = {
      vaultwarden.enable = true;
      mailserver.enable = true;
      ergo.enable = true;
      among-sus.enable = true;
      anonvote-bot.enable = true;
      heisenbridge.enable = true;
      tonsi-li.enable = true;
      minecraft.enable = true;
      websync.enable = true;
      actual.enable = true;
      radicale.enable = true; # DAV
      paperless.enable = true;

      syncthing = {
        enable = true;
        runtimeId =
          "BZQLFJM-AWGA5AG-AVNAJKH-J7P77SF-F5RXILA-QO6EFTV-G6V2NBH-6527KQL";
      };
      ckiesite = {
        enable = true;
        host = "ckie.dev";
      };
      rtc-files = {
        enable = true;
        new-fqdn = "ckie.dev";
      };
      matrix = {
        enable = true;
        host = "ckie.dev";
        serviceHost = "matrix.ckie.dev";
      };
      prometheus.enableServer = true;
      grafana = {
        enable = true;
        host = "grafana.ckie.dev";
      };
    };
    acme = {
      enable = true;
      hosts = {
        "ckie.dev" = {
          provider = "porkbun";
          extras = [
            "i.ckie.dev"
            "vw.ckie.dev"
            "flowe.ckie.dev"
            "mx.ckie.dev" # important!
            "matrix.ckie.dev"
            "janitor.matrix.ckie.dev"
            "grafana.ckie.dev"
            "actual.ckie.dev"
            "dav.ckie.dev"
            "paperless.ckie.dev"
          ];
        };

        "puppycat.house" = {
          provider = "hurricane";
          secretId = "acme-heoife";
          # FIXME: disabled until aoife can give me another acme challenge HE update token for the secret .env
          extras = [ "mei.puppycat.house" ];
        };

        "tailnet.ckie.dev" = {
          wildcard = true;
          provider = "porkbun";
        };
      };
    };
  };

  # TODO: per-server password, root too
  # users.users.ckie.hashedPassword = mkForce
  #   "$y$j9T$1kqwIyYgO/PZOuTPYhW4Q/$R7oTyggU8et7h5FA1WHjliKUBAKkofqNQEQY91N5cG1";
  security.sudo.wheelNeedsPassword = false;

  home-manager.users.ckie.home.stateVersion = "23.05";

  services.postgresql = {
    # TODO: This is usually also managed by stateVersion, but
    package = pkgs.postgresql_14_jit;
    enableJIT = true;
    # settings.max_wal_size = "10000"; # should only be enabled for reimporting a LOOOT of data
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
