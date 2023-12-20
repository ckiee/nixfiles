{ config, pkgs, lib, ... }:
with lib;

{
  imports = [ ./hardware.nix ./network.nix ../.. ];
  networking.hostName = "flowe";

  cookie = {
    restic.enable = true; # Backups
    systemd-initrd.enable = true;
    state = {
      sshPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKS46DUbCbtBGhB+dx1/B/tegqI7i6ir1ofbTmTI+yYm root@flowe";
      # tailscaleIp = "";
    };

    services = {
      vaultwarden.enable = true;
      mailserver.enable = true;
      ergo.enable = true;
      ckiesite = {
        enable = true;
        host = "ckie.dev";
      };
      rtc-files = {
        enable = true;
        new-fqdn = "ckie.dev";
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
          ];
        };

        "puppycat.house" = {
          provider = "hurricane";
          secretId = "acme-heoife";
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
