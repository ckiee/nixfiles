{ lib, config, pkgs, ... }:

let cfg = config.cookie.lutris;

in with lib; {
  options.cookie.lutris = { enable = mkEnableOption "Enables Lutris"; };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { pkgs, ... }: {
      home.packages = with pkgs; [ lutris ];
    };
    # esync
    security.pam.loginLimits = # for musnix conflict
      mkAfter [
        {
          domain = "ckie";
          item = "nofile";
          type = "soft";
          value = "1048576";
        }
        {
          domain = "ckie";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];
  };
}
