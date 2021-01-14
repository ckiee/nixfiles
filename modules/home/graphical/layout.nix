{ config, pkgs, ... }: {
  xsession.windowManager.i3.config.startup = [{
    command =
      "${pkgs.xorg.xmodmap}/bin/xmodmap /home/ron/dots/xorg/.local/share/layouts/caps*";
    notification = false;
  }];

  home.keyboard.layout = "us,il";
  home.keyboard.options = [ "grp:win_space_toggle" ];
}
