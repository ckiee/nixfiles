{ lib, config, pkgs, ... }:

let cfg = config.cookie.qsynth;

in with lib; {
  options.cookie.qsynth = {
    enable = mkEnableOption "Enables the MIDI synthesizer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ qsynth ];
    xdg.configFile."rncbc.org/Qsynth.conf".text =
      builtins.readFile ./Qsynth.conf + ''
        [SoundFonts]
        BankOffset1=0
        SoundFont1=${pkgs.soundfont-ydp-grand}/share/soundfonts/YDP-GrandPiano.sf2
      '';
  };
}
