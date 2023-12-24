{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.heisenbridge;

in with lib; {
  options.cookie.services.heisenbridge = {
    enable = mkEnableOption "heisenbridge service";
  };

  config = mkIf cfg.enable {
    services.heisenbridge = {
      enable = true;
      # address = ; # :9898
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

    # muhmuhmhum this is duplicated with the discord appservice too. and it
    # lets synapse access whatever else heisen stores there, but whatev.
    cookie.bindfs.matrix-appservice--heisenbridge = {
      source = "/var/lib/heisenbridge";
      dest = "/var/lib/matrix-synapse/heisen";
      overlay = false;
      args = "-u matrix-synapse -g matrix-synapse -p 0400,u+D";
      wantedBy = [ "matrix-synapse.service" ];
    };

    services.matrix-synapse.settings.app_service_config_files =
      [ "/var/lib/matrix-synapse/heisen/registration.yml" ];

  };
}
