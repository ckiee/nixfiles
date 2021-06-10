{ lib, config, pkgs, ... }:

let cfg = config.cookie.ipban;

in with lib; {
  options.cookie.ipban = {
    enable = mkEnableOption "Enables the firewall IP banning module";
    ips = mkOption {
      type = types.listOf types.str;
      description = "a list of ips to ban";
      default = [ "45.135.232.165" ];
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.extraCommands = "${toString (concatMapStringsSep "\n"
      (v: "iptables -I INPUT -s ${escapeShellArg v} -j DROP") cfg.ips)}";
  };
}
