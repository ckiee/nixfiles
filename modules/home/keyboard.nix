{ lib, config, pkgs, ... }:

let cfg = config.cookie.keyboard;
in with lib; {
  options.cookie.keyboard = { enable = mkEnableOption "Enables the keyboard layouts"; };

  config = mkIf cfg.enable {
    xsession.windowManager.i3.config.startup = [{
      command =
        "${pkgs.xorg.xmodmap}/bin/xmodmap ${../../ext-cfg/xmodmap-layout}";
      notification = false;
    }];

    home.keyboard.layout = "us,il";
    home.keyboard.options = [ "grp:win_space_toggle" ];
  };
}
