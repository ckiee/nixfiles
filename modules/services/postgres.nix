{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.postgres;

in with lib; {
  options.cookie.services.postgres = {
    enable = mkEnableOption "Enables the Postgres database";
    combs = mkOption rec {
      type = types.listOf types.str;
      description = "Database and user combinations";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = cfg.combs;
      ensureUsers = imap0 (index: value: ({
        name = value;
        ensurePermissions = { "DATABASE ${value}" = "ALL PRIVILEGES"; };
      })) cfg.combs;

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      # TODO: make this securer
      authentication = mkForce ''
        local all all trust
        host all all localhost trust
      '';
    };
  };
}
