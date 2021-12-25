{ lib, config, pkgs, nodes, ... }:

let
  cfg = config.cookie.wol;
  meta = config.cookie.metadata.raw;
  mac = meta.hosts.${cfg.target}.mac_address;
in with lib; {
  options.cookie.wol = {
    enable = mkEnableOption "Adds the Wake-On-Lan script";
    target = mkOption {
      type = types.str;
      description = "the machine to be awakened";
      default = "cookiemonster";
    };
    macAddress = mkOption {
      type = types.nullOr types.str;
      description = "this machine's MAC address";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = singleton
      (pkgs.writeScriptBin "wol-${cfg.target}" ''
        ${pkgs.wol}/bin/wol ${nodes.${cfg.target}.config.cookie.wol.macAddress}
      '');
  };
}
