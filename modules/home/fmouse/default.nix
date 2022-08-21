{ lib, config, pkgs, util, ... }:

let
  cfg = config.cookie.fmouse;
  modifier = config.xsession.windowManager.i3.config.modifier;

  inherit (util) mkRequiresScript;
  fmouse = mkRequiresScript ./wrapper.sh;
in with lib; {
  options.cookie.fmouse = {
    enable = mkEnableOption "Enables fmouse<->i3 integration";
  };

  config = mkIf cfg.enable {
    xsession.windowManager.i3.config.keybindings = {
      "${modifier}+a" = "exec ${fmouse}";
      "${modifier}+Shift+a" = "exec ${fmouse} --right-click";
    };
  };
}
