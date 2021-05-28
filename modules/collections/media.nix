{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.media;
in with lib; {
  options.cookie.collections.media = {
    enable = mkEnableOption "Enables a collection of multimedia apps";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ vlc mpv spotify ];
  };
}
