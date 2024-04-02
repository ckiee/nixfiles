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
        description = "Extra SQL commands to run every DB start";
        default = "";
      };
      initSql = mkOption {
        type = types.lines;
        description = "Extra SQL commands to run on the first DB start";
        default = "";
      };
      autoCreate = mkOption {
        type = types.bool;
        default = true;
        description =
          "If enabled, this instructs NixOS to auto-create the database";
      };

      ensureDBOwnership = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Grants the user ownership to a database with the same name.
        '';
      };
    };
  });
in {
  options.cookie.services.postgres = {
    enable = mkEnableOption "Postgres database";

    extraSql = mkOption {
      type = types.lines;
      description = "Extra SQL commands to run every DB start";
      default = "";
    };
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

      ensureDatabases = mapAttrsToList (name: value: name)
        (filterAttrs (name: value: value.autoCreate) cfg.comb);
      ensureUsers = mapAttrsToList (name: value: ({
        inherit name;
        ensurePermissions = { "DATABASE ${name}" = "ALL PRIVILEGES"; };
        inherit (value) ensureDBOwnership;
      })) cfg.comb;

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = mkForce ''
        local all all trust
        ${concatStringsSep "\n" (mapAttrsToList (name: value:
          (optionalString value.networkTrusted
            "host ${name} ${name} 127.0.0.1/32 trust")) cfg.comb)}
      '';

      initialScript = pkgs.writeText "ckie-postgres-init.sql"
        (concatStringsSep "\n"
          (mapAttrsToList (name: value: value.initSql) cfg.comb));
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
