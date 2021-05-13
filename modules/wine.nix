{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.wine;
  runaswine = pkgs.writeScriptBin "runaswine" ''
    ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:wine
    /run/wrappers/bin/sudo -u wine sh -c 'HOME=/home/wine USER=wine USERNAME=wine LOGNAME=wine wine "$@"'
  '';
in with lib; {
  options.cookie.wine = {
    enable = mkEnableOption
      "Enables the use of a separate user account for running Windows apps with Wine";
  };

  config = mkIf cfg.enable {
    users.users.wine = {
      isNormalUser = true;
      packages = with pkgs; [ wine ];
    };
    environment.systemPackages = [ runaswine ];
  };
}
