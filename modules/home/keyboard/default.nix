{ lib, config, pkgs, ... }:

let cfg = config.cookie.keyboard;
in with lib; {
  options.cookie.keyboard = {
    enable = mkEnableOption "keyboard layouts";
  };

  config = mkIf cfg.enable {
    home.file.".XCompose".source = ./XCompose;
    # === X11-only ===
    home.keyboard = {
      layout = "us,il";
    };
    # manpage xkeyboard-config(7)
    home.keyboard.options =
      [ "grp:win_space_toggle" "compose:rctrl" "caps:super" ];
  };
}
