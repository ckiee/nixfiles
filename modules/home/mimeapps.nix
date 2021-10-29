{ lib, config, pkgs, ... }:

let cfg = config.cookie.mimeapps;

in with lib; {
  options.cookie.mimeapps = {
    enable = mkEnableOption "Enables MIME file association configuration";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "firefox.desktop" ];
        "text/plain" = [ "emacsclientexs.desktop" ];
        "text/x-java" = [ "emacsclientexs.desktop" ];
      };
    };
  };
}
