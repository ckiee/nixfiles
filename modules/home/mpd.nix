{ sources, lib, config, nixosConfig, pkgs, ... }:

let
  cfg = config.cookie.mpd;
  sound = nixosConfig.cookie.sound;
  home = nixosConfig.cookie.user.home;
  pkgs-master = import sources.nixpkgs-master { };
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
        (optionalString (sound.pulse.enable || sound.pipewire.enable) ''
          audio_output {
            type "pulse"
            name "pulseaudio"
          }
        '') +
        # zeroconf is broken
        ''
          zeroconf_enabled "no"
        '';
    };

    systemd.user.services.mpd.Service.ExecStartPost = "${pkgs.mpc_cli}/bin/mpc crossfade 1"; # set crossfade to 1sec
    services.mpdris2 = { enable = true; };

    home.packages = with pkgs; [
      # GUI Frontends
      cantata
      # Utilities
      mpc_cli
      spotdl
      puddletag # ...for when the metadata gets messed up
    ];
  };
}
