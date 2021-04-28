{ config, lib, pkgs, ... }:

let cfg = config.cookie.dev-packages;
in with lib; {

  options.cookie.dev-packages = {
    enable = mkEnableOption "Enables some development packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs yarn rustup ];
    home.sessionPath = [ "~/.yarn/bin" ];
  };
}
