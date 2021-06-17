{ lib, config, nixosConfig, pkgs, ... }:

let
  cfg = config.cookie.mpd;
  sound = nixosConfig.cookie.sound;
  home = "/home/ckie";
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
      extraConfig =
        # PipeWire can emulate PulseAudio and it might work better sometimes
        mkIf (sound.pulse.enable || sound.pipewire.enable) ''
          audio_output {
            type "pulse"
            name "pulseaudio"
          }
        '';
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
