{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.music;
in with lib; {
  options.cookie.collections.music = {
    enable = mkEnableOption "Enables a collection of music-creation programs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      helio-workstation
      bespokesynth
      musescore
    ];

    home-manager.users.ckie = { config, ... }: {
      home.file."Documents/BespokeSynth".source =
        (config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/Sync/BespokeSynth");
      home.file."Documents/Helio".source = (config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Sync/Helio");
      home.file."Documents/MuseScore3".source =
        (config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/Sync/MuseScore3");
    };
  };
}
