{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.mpd;
  home = config.home.homeDirectory;
in with lib; {
  options.cookie.mpd = {
    enable = mkEnableOption "Enables the music player daemon";
  };

  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      dataDir = "${home}/Sync/mpd";
      dbFile = "${home}/Sync/.mpd-db";
      musicDirectory = "${home}/Music/flat";
    };
    services.mpdris2 = { enable = true; };

    home.packages = with pkgs; [
      # GUI Frontends
      cantata
      # Utilities
      mpc_cli
      spotdl
    ];
  };
}
