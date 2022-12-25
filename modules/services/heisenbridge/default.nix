{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.heisenbridge;

in with lib; {
  options.cookie.services.heisenbridge = {
    enable = mkEnableOption "Enables the heisenbridge service";
  };

  config = mkIf cfg.enable {
    services.heisenbridge = {
      enable = true;
      address = config.cookie.state.tailscaleIp; # :9898
      debug = true; # FIXME
      homeserver = if config.cookie.services.matrix.enable then
        "http://[::1]:8008"
      else
        throw "heisenbridge: what's the homeserver URL?";
      owner = "@ckie:ckie.dev";
      namespaces = {
        users = [{
          regex = "@heisen_.*";
          exclusive = true;
        }];
        aliases = [ ];
        rooms = [ ];
      };
    };

    systemd.services.heisenbridge.before = singleton "matrix-synapse.service";
    services.matrix-synapse.settings.app_service_config_files =
      [ "/var/lib/heisenbridge/registration.yml" ];

  };
}
