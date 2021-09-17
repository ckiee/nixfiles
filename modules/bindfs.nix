{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.cookie.bindfs;

  bindfs = types.submodule {
    options = {
      source = mkOption {
        type = types.str;
        description = "the source path";
      };

      dest = mkOption {
        type = types.nullOr types.str;
        description = "where to mount the bindfs";
        default = null;
      };

      args = mkOption {
        default = "-M ckie,@nginx";
        type = types.str;
        description = "bindfs arguments";
      };

      wantedBy = mkOption {
        type = types.listOf types.str;
        description = "systemd objects that depend on this bindfs";
        default = [ ];
      };

      overlay = mkOption {
        type = types.bool;
        description = "whether the bindfs should manage the directory";
        default = false;
      };
    };
  };

  mkService = name:
    { source, dest, wantedBy, args, overlay, ... }: {
      description = "mount bindfs for ${name}";
      after = [ "local-fs.target" ];
      wantedBy = [ "local-fs.target" ] ++ wantedBy;

      serviceConfig.Type = "forking";

      preStart = with pkgs; ''
        ${optionalString (!overlay) ''
          ${coreutils}/bin/mkdir '${dest}' || true
        ''}
        ${optionalString overlay ''
          ${coreutils}/bin/mkdir '${source}' || true
          ${coreutils}/bin/chmod -R 000 ${"'${source}'"}
          ${coreutils}/bin/chown -R 0:0 ${"'${source}'"}
        ''}
      '';
      script = "${pkgs.bindfs}/bin/bindfs ${args} '${source}' '${
          if overlay then source else dest
        }'";
    };
in {
  options.cookie.bindfs = mkOption {
    type = types.attrsOf bindfs;
    description = "bindfs configuration";
    default = { };
  };

  config = {
    assertions = mapAttrsToList (key: val: {
      # There's no XOR operator ):
      assertion = (!((val.overlay && (val.dest != null))
        || (!val.overlay && (val.dest == null))));
      message = "${key}: the overlay and dest options conflict";
    }) cfg;

    systemd.services = let
      units = mapAttrs' (name: info: {
        name = "${name}-bindfs";
        value = (mkService name info);
      }) cfg;
    in units;
  };
}
