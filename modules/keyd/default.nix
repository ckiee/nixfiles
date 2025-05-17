{ lib, config, pkgs, ... }:

let cfg = config.cookie.keyd;

in with lib; {
  options.cookie.keyd = { enable = mkEnableOption "keyd"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ keyd ];
    services.keyd = {
      enable = true;
      keyboards = {
        gk600 = {
          ids = [ "0db0:ea47" ];
          settings = { "shift+meta" = { f23 = "rightcontrol"; }; };
        };
      };
    };
  };
}
