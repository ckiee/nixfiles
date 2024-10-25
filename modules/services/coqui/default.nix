{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.coqui;

in with lib; {
  options.cookie.services.coqui = { enable = mkEnableOption "Coqui TTS"; };

  config = mkIf cfg.enable {
    # socket
    systemd.sockets.coqui-proxy = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "5001" ]; # TODO:localhost
      socketConfig.Service = [ "coqui-proxy.service" ];
    };

    # -> proxy
    systemd.services.coqui-proxy = rec {
      requires = [ "coqui-proxy.socket" ];
      bindsTo = [ "docker-coqui.service" ];
      after = [ "docker-coqui.service" "coqui-proxy.socket" ];
      path = with pkgs; [ curl ];
      preStart = ''
        # poll till its up
        while true; do curl 127.0.0.1:5002 &>/dev/null && exit 0; sleep .1; done
      '';
      serviceConfig = {
        Type = "notify";
        ExecStart =
          "/run/current-system/systemd/lib/systemd/systemd-socket-proxyd"
          + " --exit-idle-time 5min" + " 127.0.0.1:5002";
      };
    };

    # -> coqui!
    systemd.services.docker-coqui = { unitConfig.StopWhenUnneeded = true; };
    virtualisation.oci-containers.containers.coqui = {
      image =
        "ghcr.io/coqui-ai/tts-cpu:eef419b37393b11cc741662d041d8d793e011f2d";
      ports = [ "127.0.0.1:5002:5002" ];
      entrypoint = "python3";
      cmd = [ "TTS/server/server.py" "--model_name" "tts_models/en/vctk/vits" ];
      autoStart = false;
    };
  };
}
