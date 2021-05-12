{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.wine;
  runaswine = pkgs.writeScriptBin "runaswine" ''
    ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:wineuser
    ${pkgs.sudo}/bin/sudo -u wineuser env HOME=/home/wineuser USER=wineuser USERNAME=wineuser LOGNAME=wineuser wine "$@"
  '';
in with lib; {
  options.cookie.wine = {
    enable = mkEnableOption
      "Enables the use of a separate user account for running Windows apps with Wine";
  };

  config.wine = mkIf cfg.enable {
    users.users.wine = { isNormalUser = true; };
    environment.systemPackages = [ runaswine ];
  };
}
