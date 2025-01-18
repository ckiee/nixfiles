{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.archivebox;

in with lib; {
  options.cookie.services.archivebox = {
    enable = mkEnableOption "ArchiveBox on Tailnet";
    host = mkOption {
      type = types.str;
      default = "arc.tailnet.ckie.dev";
      description = "nginx vhost";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "archivebox" ''
        exec sudo docker run -it -v /var/lib/archivebox:/data archivebox/archivebox /usr/local/bin/archivebox "$@"
      '')
    ];

    virtualisation.oci-containers.containers."archivebox-archivebox" = {
      image = "archivebox/archivebox:latest";
      environment = {
        "ALLOWED_HOSTS" = "*";
        "CSRF_TRUSTED_ORIGINS" = "http://localhost:8000";
        "PUBLIC_ADD_VIEW" = "False";
        "PUBLIC_INDEX" = "True";
        "PUBLIC_SNAPSHOTS" = "True";
        "SEARCH_BACKEND_ENGINE" = "sonic";
        "SEARCH_BACKEND_HOST_NAME" = "sonic";
        "SEARCH_BACKEND_PASSWORD" =
          fileContents ../../../secrets/archivebox-sonic-pw;
      };
      volumes = [ "/var/lib/archivebox:/data:rw" ];
      ports = [ "12382:8000/tcp" ];
      log-driver = "journald";
    };

    cookie.restic.paths = [
      # not backing up the archive itself XD
      "/var/lib/archivebox/index.sqlite3"
      "/var/lib/archivebox/ArchiveBox.conf"
    ];

    services.nginx = {
      virtualHosts.${cfg.host} = {
        locations."/" = { proxyPass = "http://127.0.0.1:12382"; };
        extraConfig = ''
          access_log /var/log/nginx/archivebox.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "archivebox" ];
  };
}
