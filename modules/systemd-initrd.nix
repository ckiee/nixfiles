{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.systemd-initrd;
  hostname = config.networking.hostName;
in with lib; {
  options.cookie.systemd-initrd = {
    enable = mkEnableOption
      "NixOS systemd-in-initrd with remote unlock and networking";
  };

  config = mkIf cfg.enable {
    cookie.secrets.systemd-initrd-ssh-host-key = {
      source = "./secrets/systemd-initrd-ssh-host-${hostname}";
      permissions = "0400";
      generateCommand = ''
        ssh-keygen -t ed25519 -f 'secrets/systemd-initrd-ssh-host-${hostname}' -C "generated $(date --iso=seconds)" -N ""
      '';
    };

    # we previously set
    #   boot.initrd.systemd.network.useDHCP = true; # TODO: depends on https://github.com/NixOS/nixpkgs/pull/242158
    # but it's too much of a pain to rebase
    networking.useDHCP = true;

    boot.initrd = {
      enable = true;
      systemd.enable = true;
      # since size probably isn't a problem, let's pack every
      # network driver one of our machines could need:
      availableKernelModules = [ "r8169" "e1000e" ];

      network = {
        enable = true;
        flushBeforeStage2 =
          true; # we get multiple local ipv4's which confuse chromium

        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = [ (readFile ../deploy/id_ed25519.pub) ];
          # no idea what this means, copied from the nixos test:
          # > Terrible hack so it works with useBootLoader
          # > hostKeys =
          # >   [{ outPath = "${./initrd-network-ssh/ssh_host_ed25519_key}"; }];
          hostKeys = [ config.cookie.secrets.systemd-initrd-ssh-host-key.dest ];
        };
      };
    };
  };
}
