{ pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "xrender";
    fade = true;
    fadeDelta = 5;
    inactiveOpacity = "0.8";
    opacityRule = [ "90:class_g *?= 'Rofi'" ];
    shadow = true;
    shadowExclude = [
      "name = 'Notification'"
      "class_g ?= 'Notify-osd'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    shadowOffsets = [ (-7) (-7) ];
    vSync = true;
  };
}
