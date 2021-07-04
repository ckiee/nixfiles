{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ../.. ];

  cookie = {
    services = {
      owo-bot.enable = true;
      ffg-bot.enable = true;
      comicfury.enable = true;
      minecraft.enable = true;
      matterbridge.enable = true;
      rtc-files.enable = true;
      mailserver.enable = true;

      prometheus.enable = true;
      grafana = {
        enable = true;
        host = "grafana.ckie.dev";
      };

      ronthecookieme = {
        enable = true;
        host = "ronthecookie.me";
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
          extras = [ "matrix.ckie.dev" "i.ckie.dev" "bokkusu.ckie.dev" ];
        };
      };
    };
  };

  networking = {
    hostName = "bokkusu";
    networkmanager.insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
