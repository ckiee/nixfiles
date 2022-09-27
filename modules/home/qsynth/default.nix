{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.qsynth;
  soundfonts = [
    "${pkgs.soundfont-generaluser}/share/soundfonts/GeneralUser-GS.sf2"
    "${pkgs.soundfont-ydp-grand}/share/soundfonts/YDP-GrandPiano.sf2"
    ./00Shackled_Steinway_B-IGVERB_Version.sf2
    ./CP-80.sf2
  ];
in with lib; {
  options.cookie.qsynth = {
    enable = mkEnableOption "Enables the MIDI synthesizer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ qsynth ];
    xdg.configFile."rncbc.org/Qsynth.conf".text =
      builtins.readFile ./Qsynth.conf + ''
        [SoundFonts]
        ${concatStringsSep "\n" (imap (i: f: ''
          BankOffset${toString i}
          SoundFont${toString i}=${f}'') soundfonts)}
      '';
  };
}
