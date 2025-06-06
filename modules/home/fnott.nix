{ lib, config, pkgs, nixosConfig, ... }:

let
  desktopCfg = nixosConfig.cookie.desktop;
  cfg = config.cookie.fnott;

in with lib; {
  options.cookie.fnott = {
    enable = mkEnableOption "fnott notification daemon";
  };

  config = mkIf cfg.enable {
    services.fnott = {
      enable = true;
      settings = {
        main = {
          output = desktopCfg.monitors.primary;
          title-font = "monospace:size=12";
          title-format = "%a%A";
          summary-font = "monospace:size=12";
          body-font = "monospace:size=12";
          default-timeout = 10;
          idle-timeout = 5;
          # per-urg defaults
          background = "212121f2";
          border-size = 0;
          title-color = "ffffffff";
          summary-color = "ffffffff";
          body-color = "ffffffff";
        };
      };
    };
  };
}
