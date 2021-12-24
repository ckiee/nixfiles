{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.ssh;

in with lib; {
  options.cookie.services.ssh = {
    enable = mkEnableOption "Enables the OpenSSH daemon and Mosh";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      forwardX11 = true;
      permitRootLogin = mkForce
        "no"; # for the "install" host this is enabled, so we force it away
      passwordAuthentication = false;
    };
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
  };
}
