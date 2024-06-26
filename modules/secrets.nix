{ util, pkgs, config, lib, ... }:

with lib;
with util;

let
  cfg = config.cookie.secrets;

  secret = types.submodule ({ config, ... }: {
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

      generateCommand = mkOption {
        type = types.nullOr types.str;
        description =
          "a shell command to generate the secret if it does not already exist";
        default = null;
      };
    };
  });

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
          ./.. + "/encrypted/${config.networking.hostName}/${baseNameOf source}"
        }'

        chown '${owner}':'${group}' '${dest}'
        chmod '${permissions}' '${dest}'
      '';
      script = ''
        ${optionalString (wantedBy != null) ''
        # TODO: inspect the start reason for *this* -key unit to see whether this is appropiate
        systemctl try-reload-or-restart ${escapeShellArg wantedBy}
        ''}
        sleep infinity
      '';
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
    in units;
  };
}
