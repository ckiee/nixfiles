{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ../.. ];
  # We have fast network:
  deployment.substituteOnDestination = true;

  users.users.liz = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDx/9/XV672YOSy2NbuTQCBzego3MSI3CXhMXgO3CaYxrIQ/Cba6kN07E0CP62mAVLl+1dYVs93zZVc+Pe1OzNjng8JZUoF36Ps+YudTC4E4Ksv0X9hnMN74yNnUvC2ORtQLbNx6bGWfZlKWZ71wATclDfp1WK4t7XysPz4kqSBaUci0SGwR8LN8v15Wiq2mQKtjRhOXvlLG6N0Ti6sLD3MEVYVoaP/TDX2J09sgy89Zz6Osz9hxnQZpcQxZvd1caj7PgBL7ytf3zCALLqSnBMgbh/QkvN75Dkwd1EeCVlf7TEo/MQoWGyB9D1pq5ZibqNh6R6T6pV7aps+8VDyWuJ5b/MB+oFOX8qm6XnEvCyxxih2eKb76Wt78ypEgL5bKIQVkC5yES2v2H0sSPgvT/ssjLu4P6re8KiWsYQbp9pI0jX+ih1U+v0l8fovUV7x34H/J57BF7aFJoGaZlqmDMLomy09g84fEFIiGeaVh8ukXi53VGI7V1Yj2t6eJIwoFI8=
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA43Kf9c1oY6WWa7Incn2lU9Exj66bkhzgjMIzulzpXJP21/lJMDxsWZ5hNrePhbRycmHLnRECJMEoWtm3F9CZrhmAbNry/i0abg+e0oM6I8T1H1/vHy+ljEIaZBdADZhNqwvQgk0Z4b6Mk+U6p2t4hY7jD8RWIeQU+e6FuWrPaE1KP3FQ/4Srqh5QlKazF7lgJwxyeL/TxGA6EF7HdVeIGPA55+w0OXQP14yH+EYrFrnotOvI+ThVztJ6+HSAbjKdxlbwj+d0WbuG2KfD3ksBadk4I8kHJJYNcwe84RuS95PdxauBmhxdwhU0a5YzPWzCN9NKpb1jbigAqCVkfTv3ETVcOu+KC5+CNP68Bxs+XFviHrFOsDblZOFHEKdSx9MCSHpSICbMT5Iqftm+B7YFR/T60Dyt2pM7GeTUpe0Zch9I1wMI+Mei7j8EnrfxPYOBe2zNpmDAAg73qXuFL1EU/CmJQlDCAShz9UJNb4uCIF9UGm0VRefI+BlVChB/8N0=
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGfHnvfb/ShVhEEoJCoTl6T7J0EhxorCCgET5oClY5R ''];
  };

  cookie = {
    restic.enable = true; # Backups
    services = {
      owo-bot.enable = true;
      ffg-bot.enable = true;
      minecraft.enable = true;
      matterbridge.enable = true;
      rtc-files.enable = true;
      mailserver.enable = true;
      among-sus.enable = true;
      anonvote-bot.enable = true;

      prometheus.enable = true;
      grafana = {
        enable = true;
        host = "grafana.ckie.dev";
      };
      ronthecookieme = {
        enable = true;
        host = "ronthecookie.me";
      };
      ckiesite = {
        enable = true;
        host = "ckie.dev";
      };
      redirect-farm = {
        enable = true;
        host = "u.ronthecookie.me";
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
    };
    acme = {
      enable = true;
      hosts = {
        "ronthecookie.me" = { };
        "znc.ronthecookie.me" = { };
        "i.ronthecookie.me" = { };
        "u.ronthecookie.me" = { };
        "ckie.dev" = {
          provider = "porkbun";
          extras = [
            "matrix.ckie.dev"
            "i.ckie.dev"
            "bokkusu.ckie.dev"
            "grafana.ckie.dev"
            "znc.ckie.dev"
            "tailnet.ckie.dev"
          ];
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
