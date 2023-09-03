{ lib, config, pkgs, ... }:

let cfg = config.cookie.keyboard;
in with lib; {
  options.cookie.keyboard = {
    enable = mkEnableOption "keyboard layouts";
  };

  config = mkIf cfg.enable {
    home.keyboard = {
      layout = "us,us,il";
      variant = ",colemak,";
    };
    # manpage xkeyboard-config(7)
    home.keyboard.options =
      [ "grp:win_space_toggle" "compose:rctrl" "caps:super" ];

    home.file.".XCompose".source = ./XCompose;
  };
}
