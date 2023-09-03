{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.ssh;

in with lib; {
  options.cookie.services.ssh = {
    enable = mkEnableOption "OpenSSH daemon and Mosh";
    # unused, but maybe it should be? idk, this config is public after all.
    useAlternatePort =
      mkEnableOption "Exposes the SSH server on port 2222 instead";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = mkForce
          "no"; # for the "install" host this is enabled, so we force it away
        PasswordAuthentication = false;
      };
      ports = mkIf cfg.useAlternatePort (mkForce [ 2222 ]);
      # Listen on the usual port on tailscale
      listenAddresses = mkIf cfg.useAlternatePort [
        {
          addr = config.cookie.state.tailscaleIp;
          port = 22;
        }
        {
          addr = "0.0.0.0";
          port = 2222;
        }
      ];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf cfg.useAlternatePort [ 22 2222 ];

    services.fail2ban = mkIf config.networking.firewall.enable {
      enable = true;
      maxretry = 1;
    };

    environment.systemPackages = with pkgs; [ mosh ];
    # Mosh ports
    networking.firewall.allowedUDPPortRanges = [{
      from = 60000;
      to = 61000;
    }];

    cookie.user.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
    # Pin a few services' SSL keys
    programs.ssh.knownHostsFiles = [ ./known_hosts ];
  };
}
