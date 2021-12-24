{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.st;
  st = pkgs.st.override {
    conf = builtins.readFile ./st.h;
    patches = [
      ./patches/st-scrollback-20201205-4ef0cbd.diff
      ./patches/st-scrollback-mouse-20191024-a2c479c.diff
      ./patches/st-scrollback-mouse-altscreen-20200416-5703aa0.diff
      ./patches/st-blinking_cursor-20200531-a2a7044.diff
      ./patches/st-alpha-0.8.2.diff
      ./patches/0001-terminfo-add-24-bit-color-support.patch
    ];
  };
in with lib; {
  options.cookie.st = {
    enable = mkEnableOption "Enables the suckless terminal";
  };

  config = {
    environment.systemPackages = singleton st;
  };
}
