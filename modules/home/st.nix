{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.st;
  st = pkgs.st.override {
    conf = builtins.readFile ../../ext/st.h;
    patches = [
      ../../ext/st-patches/st-scrollback-20201205-4ef0cbd.diff
      ../../ext/st-patches/st-scrollback-mouse-20191024-a2c479c.diff
      ../../ext/st-patches/st-scrollback-mouse-altscreen-20200416-5703aa0.diff
      ../../ext/st-patches/st-blinking_cursor-20200531-a2a7044.diff
      ../../ext/st-patches/st-alpha-0.8.2.diff
    ];
  };
in with lib; {
  options.cookie.st = {
    enable = mkEnableOption "Enables the suckless terminal";
  };

  config = {
    home.packages = [ st ];
    xsession.windowManager.i3.config.terminal = "${st}/bin/st";
  };
}
