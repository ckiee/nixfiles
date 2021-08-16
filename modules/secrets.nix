{ pkgs, config, lib, ... }:

with lib;

let
  isRagerBuild = (builtins.getEnv "COOKIE_RAGER_BUILD" != "");
  cfg = config.cookie.secrets;
  filenameFromPath = path: last (splitString "/" path);
  # This is defined in the Makefile, so it's not perfect:
  nixfilesPath =
    warnIf ((builtins.getEnv "COOKIE_TOPLEVEL" == "") && !isRagerBuild)
    "COOKIE_TOPLEVEL is empty. You have to be inside the shell."
    (builtins.getEnv "COOKIE_TOPLEVEL");

  secret = types.submodule {
    options = {
      source = mkOption {
        type = types.str;
        description = "local secret path relative to the repo";
      };

      dest = mkOption {
        type = types.str;
        description = "where to write the decrypted secret to";
      };

      owner = mkOption {
        default = "root";
        type = types.str;
        description = "who should own the secret";
      };

      group = mkOption {
        default = "root";
        type = types.str;
        description = "what group should own the secret";
      };

      permissions = mkOption {
        example = "0400";
        type = types.str;
        description = "Permissions expressed as octal.";
      };

      wantedBy = mkOption {
        type = types.nullOr (types.str);
        description = "a systemd object that depends on this secret";
        default = null;
      };
    };
  };

  metadata = config.cookie.metadata.raw;

  mkService = name:
    { source, dest, owner, group, permissions, wantedBy, ... }: {
      description = "decrypt secret for ${name}";
      wantedBy = [ "multi-user.target" ]
        ++ optional (wantedBy != null) wantedBy;

      serviceConfig.Type = "oneshot";

      preStart = with pkgs; ''
        rm -rf ${dest}
        "${rage}"/bin/rage -d -i /etc/ssh/ssh_host_ed25519_key -o '${dest}' '${
          /. + "${nixfilesPath}/encrypted/${config.networking.hostName}/${
            filenameFromPath source
          }"
        }'

        chown '${owner}':'${group}' '${dest}'
        chmod '${permissions}' '${dest}'
      '';
      script = "true";
    };
in {
  options.cookie.secrets = mkOption {
    type = types.attrsOf secret;
    description = "secret configuration";
    default = { };
  };

  config = {
    systemd.services = let
      units = mapAttrs' (name: info: {
        name = "${name}-key";
        value = (mkService name info);
      }) cfg;
    in mkIf (!isRagerBuild) units;

    environment.extraSetup = let
      host = config.networking.hostName;
      pubkey = metadata.hosts.${host}.ssh_pubkey;
      cookie-rager-encrypt = pkgs.writeScript "cookie-rager-encrypt" ''
        set -e
        COOKIE_TOPLEVEL="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
        cd "$COOKIE_TOPLEVEL"
        rm -rf encrypted/'${host}' || true
        mkdir -p encrypted/'${host}'
        ${concatStringsSep "\n" (mapAttrsToList (_: secret:
          "${pkgs.rage}/bin/rage -a -r '${pubkey}' -o 'encrypted/${host}/${
            filenameFromPath secret.source
          }' '${secret.source}'") cfg)}
      '';
    in mkIf isRagerBuild
    "ln -s ${cookie-rager-encrypt} $out/cookie-rager-encrypt";
  };
}
