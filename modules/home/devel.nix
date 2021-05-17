{ config, lib, pkgs, ... }:

let cfg = config.cookie.devel;
in with lib; {

  options.cookie.devel = {
    enable = mkEnableOption "Enables some development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs yarn rustup maven platformio gcc gh ];
    home.sessionPath = [ "~/.yarn/bin" ];
  };
}
