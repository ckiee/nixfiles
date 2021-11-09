{ pkgs, config, lib, ... }:

with lib;

let
  isRagerBuild = (builtins.getEnv "COOKIE_RAGER_BUILD" != "");
  userPubkey = fileContents ../ext/id_ed25519.pub;
  cfg = config.cookie.secrets;
  filenameFromPath = path: last (splitString "/" path);

  secret = types.submodule ({config,...}: {
    options = {
      source = mkOption {
        type = types.str;
        description = "local secret path relative to the repo";
      };

      dest = mkOption {
        type = types.str;
        description = "where to write the decrypted secret to";
        default = "/run/keys/${config._module.args.name}";
      };

      owner = mkOption {
        type = types.str;
        description = "who should own the secret";
        default = "root";
      };

      group = mkOption {
        type = types.str;
        description = "what group should own the secret";
        default = "root";
      };

      permissions = mkOption {
        type = types.str;
        description = "permissions expressed as octal";
        default = "0000"; # lock it down if the user is being silly
        example = "0400";
      };

      wantedBy = mkOption {
        type = types.nullOr types.str;
        description = "a systemd object that depends on this secret";
        default = null;
      };

      runtime = mkOption {
        # The encryption mechanism will not work on some unregistered files
        # that can't be encrypted so we register them anyway
        type = types.bool;
        description = "whether this secret should be available at runtime";
        default = true;
      };
    };
  });

  metadata = config.cookie.metadata.raw;

  mkService = name:
    { source, dest, owner, group, permissions, wantedBy, ... }: {
      description = "decrypt secret for ${name}";
      wantedBy = [ "multi-user.target" ]
        ++ optional (wantedBy != null) wantedBy;

      serviceConfig.Type = "simple";

      # This needs to be in preStart so if anyone depends on us
      # we'll actually be done by the time systemd thinks we're "active".
      preStart = with pkgs; ''
        rm -f ${dest}
        "${rage}"/bin/rage -d -i /etc/ssh/ssh_host_ed25519_key -o '${dest}' '${
          ./.. + "/encrypted/${config.networking.hostName}/${
            filenameFromPath source
          }"
        }'

        chown '${owner}':'${group}' '${dest}'
        chmod '${permissions}' '${dest}'
      '';
      script = "sleep infinity";
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
      }) (filterAttrs (_: secret: secret.runtime) cfg);
    in mkIf (!isRagerBuild) units;

    environment.extraSetup = let
      host = config.networking.hostName;
      pubkey = metadata.hosts.${host}.ssh_pubkey;
      cookie-rager-encrypt = pkgs.writeScript "cookie-rager-encrypt" ''
        # Some environment (PATH, pwd) for this is set in our wrapper script, rager
        set -e
        rm -rf encrypted/'${host}' || true
        mkdir -p encrypted/'${host}'
        ${concatStringsSep "\n" (mapAttrsToList (_: secret:
          "rage -a -r '${pubkey}' -r '${userPubkey}' -o 'encrypted/${host}/${
            filenameFromPath secret.source
          }' '${secret.source}'") cfg)}
      '';
    in mkIf isRagerBuild
    "ln -s ${cookie-rager-encrypt} $out/cookie-rager-encrypt";
  };
}
