{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ../.. ];
  # We have fast network:
  deployment.substituteOnDestination = true;

  cookie = {
    services = {
      minecraft = {
        enable = true;
        heapAllocation = "1G";
      };
      rtc-files = {
        enable = true;
        old-fqdn = "old.i.berryshine.ckie.dev";
        new-fqdn = "new.i.berryshine.ckie.dev";
      };
      ckiesite = {
        enable = true;
        host = "ckie.dev";
      };
    };
    acme = {
      enable = true;
      hosts = {
        "ckie.dev" = {
          provider = "porkbun";
          extras = [
            "old.i.berryshine.ckie.dev"
            "new.i.berryshine.ckie.dev"
          ];
        };
      };
    };
  };

  networking = {
    hostName = "berryshine";
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
