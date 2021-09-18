{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.services.postgres;

  combType = types.attrsOf (types.submodule {
    options = {
      networkTrusted = mkOption {
        type = types.bool;
        description =
          "Whether this combination needs to be able to connect over the network";
        default = false;
      };
    };
  });
in {
  options.cookie.services.postgres = {
    enable = mkEnableOption "Enables the Postgres database";

    comb = mkOption {
      type = combType;
      description = "postgres user-database combination configuration";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    cookie.restic.enablePostgres = true; # enable postgres backup support

    services.postgresql = {
      enable = true;

      ensureDatabases = mapAttrsToList (name: value: name) cfg.comb;
      ensureUsers = mapAttrsToList (name: value: ({
        inherit name;
        ensurePermissions = { "DATABASE ${name}" = "ALL PRIVILEGES"; };
      })) cfg.comb;

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = mkForce ''
        local all all trust
        ${concatStringsSep "\n" (mapAttrsToList (name: value:
          (optionalString value.networkTrusted
            "host ${name} ${name} localhost trust")) cfg.comb)}
      '';
    };
  };
}
