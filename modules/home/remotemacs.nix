{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.remotemacs;
  targetHost = "cookiemonster";
  # YAML is a superset of JSON now, so this is okay (:
  termConfig = pkgs.writeText "alacritty.yml" (builtins.toJSON {
    window.dimensions = {
      columns = 174;
      lines = 46;
    };
  });
  wrapper = pkgs.writeShellScriptBin "remotemacs" ''
    # the unset works around https://github.com/mobile-shell/mosh/issues/1134
    ${pkgs.alacritty}/bin/alacritty --config-file ${termConfig} -t 'Emacs-over-ssh' -e ssh ${targetHost} -t "unset SSH_TTY && emacsclient -nw"
  '';
  desktopItem = pkgs.makeDesktopItem {
    name = "remotemacs";
    exec = "${wrapper}/bin/remotemacs";
    desktopName = "Emacs-over-ssh";
  };
in with lib; {
  options.cookie.remotemacs = {
    enable = mkEnableOption "Enables the fast Emacs-over-ssh functionality";
  };

  config = mkIf cfg.enable {
    home.packages = [ wrapper desktopItem ];
  };
}
