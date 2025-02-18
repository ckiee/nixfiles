{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.transqsh;

in with lib; {
  options.cookie.services.transqsh = {
    enable = mkEnableOption "the transqsh service";
  };

  config = mkIf cfg.enable {
    cookie.services.syncthing.folders."transqsh" = {
      id = "transqoosh"; # mobius sync state cursed on iphone
      path = "${config.cookie.user.home}/.transqsh";
      devices = [ "cookiemonster" "iphone" ];
    };

    environment.systemPackages = [ pkgs.cookie.transqsh ];

    systemd.user.services.transqsh = {
      description = "Transqsh";
      startAt = "hourly";
      path = [ pkgs.cookie.transqsh ];

      unitConfig.ConditionUser = "ckie"; # cookie.user
      script = ''
        transqsh --codec aac ~/Music/flat ~/.transqsh
      '';
    };

  };
}
