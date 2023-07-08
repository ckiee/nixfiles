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

    boot.initrd = {
      enable = true;
      systemd.enable = true;
      network.ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          (readFile (../secrets + "/systemd-initrd-ssh-host-${hostname}.pub"))
        ];
        # no idea what this means, copied from the nixos test:
        # > Terrible hack so it works with useBootLoader
        # > hostKeys =
        # >   [{ outPath = "${./initrd-network-ssh/ssh_host_ed25519_key}"; }];
        hostKeys = [ config.cookie.secrets.systemd-initrd-ssh-host-key.dest ];
      };
    };
  };
}
