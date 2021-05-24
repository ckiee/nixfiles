{ lib, config, pkgs, ... }:

let cfg = config.cookie.ssh;

in with lib; {
  options.cookie.ssh = {
    enable = mkEnableOption "Enables the OpenSSH daemon and Mosh";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      forwardX11 = true;
    };

    environment.systemPackages = with pkgs; [ mosh ];
  };
}
