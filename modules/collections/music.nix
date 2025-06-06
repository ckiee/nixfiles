{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.music;
in with lib; {
  options.cookie.collections.music = {
    enable = mkEnableOption "Enables a collection of music-creation programs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      helio-workstation
      (bespokesynth.override { enableVST2 = true; })
      musescore # 4 is meh (used to have "musescore3 pkg but it bork")

      # TODO: this should really be merged with home/ardour.nix into
      # a /modules/music/* megamodule like matrix or prom
      surge
      surge-XT

      lsp-plugins.out # very noisy plugin set in the list
      zita-at1
      zyn-fusion
      qsampler
      # linuxsampler
      guitarix
      calf
    ];

    home-manager.users.ckie = { config, ... }: {
      # Map workstation settings & project files to Syncthing
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
