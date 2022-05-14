{ lib, config, pkgs, ... }:

with lib;
with builtins;

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
      extraSql = mkOption {
        type = types.lines;
        description = "Extra SQL commands to run every db start";
        default = "";
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
            "host ${name} ${name} 127.0.0.1/32 trust")) cfg.comb)}
      '';
    };

    systemd.services.postgresql.postStart = mkAfter ''
      ${concatStringsSep "\n" (mapAttrsToList (name: value:
        "$PSQL -tAf ${
          pkgs.writeText "${name}-ckpg-init.sql" (''
            \c ${name};
            ${value.extraSql}
          '')
        }") cfg.comb)}
    '';
  };
}
