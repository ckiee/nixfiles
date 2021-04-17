{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.st;
  st = pkgs.st.override { conf = builtins.readFile ../../ext-cfg/st.h; };
in with lib; {
  options.cookie.st = {
    enable = mkEnableOption "Enables the suckless terminal";
  };

  config = {
    home.packages = [ st ];
    xsession.windowManager.i3.config.terminal = "${st}/bin/st";
  };
}
