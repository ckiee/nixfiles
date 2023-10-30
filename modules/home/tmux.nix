{ lib, config, pkgs, ... }:

let cfg = config.cookie.tmux;

in with lib; {
  options.cookie.tmux = {
    enable = mkEnableOption "Enables tmux";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      escapeTime = 20;
    };
  };
}
