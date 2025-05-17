{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.mattermost;

in with lib; {
  options.cookie.services.mattermost = {
    enable = mkEnableOption "mattermost cht";
    host = mkOption {
      type = types.str;
      default = "mt.pupc.at";
    };
  };

  config = mkIf cfg.enable {
    cookie.services = {
      nginx.enable = true;
      postgres.enable = true;
    };

    environment.systemPackages = [ config.services.mattermost.package ];

    services.mattermost = {
      enable = true;
      package = pkgs.mattermost.withoutTests;
      database = {
        driver = "postgres";
        peerAuth = true;
      };
      preferNixConfig = true;
      siteUrl = "https://${cfg.host}";
      port = 12483;
      socket = {
        enable = true;
        # Exporting the control socket will add `mmctl` to your PATH, and export
        # MMCTL_LOCAL_SOCKET_PATH systemwide. Otherwise, you can get the socket
        # path out of `config.mattermost.socket.path` and set it manually.
        export = true;
      };
      settings = {
        LogSettings.ConsoleLevel = "INFO";
        ServiceSettings.AllowedUntrustedInternalConnections = # {daiko,cookiemonster-dev}.tailnet
          "${nodes.cookiemonster.config.cookie.state.tailscaleIp},${config.cookie.state.tailscaleIp},cookiemonster-dev.tailnet.ckie.dev,daiko.tailnet.ckie.dev";
      };
    };

    cookie.restic.paths = [ config.services.mattermost.dataDir ];

    services.nginx.virtualHosts = {
      "${cfg.host}" = {
        forceSSL = true;
        locations = {
          "/" = {
            recommendedProxySettings = true;
            proxyWebsockets = true;
            proxyPass = "http://localhost:12483";
          };
        };
      };
    };

  };
}
