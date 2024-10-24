{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.coqui;

in with lib; {
  options.cookie.services.coqui = { enable = mkEnableOption "Coqui TTS"; };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.coqui = {
      image = "ghcr.io/coqui-ai/tts-cpu:eef419b37393b11cc741662d041d8d793e011f2d";
      ports = [ "127.0.0.1:5002:5002" ];
      autoStart = true;
      entrypoint = "python3";
      cmd = [ "TTS/server/server.py" "--model_name" "tts_models/en/vctk/vits" ];
    };
  };
}
