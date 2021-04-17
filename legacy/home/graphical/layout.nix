{ config, pkgs, ... }: {
  xsession.windowManager.i3.config.startup = [{
    command = "${pkgs.xorg.xmodmap}/bin/xmodmap ${./xmodmap-layout}";
    notification = false;
  }];

  home.keyboard.layout = "us,il";
  home.keyboard.options = [ "grp:win_space_toggle" ];
}
