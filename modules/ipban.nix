{ lib, config, pkgs, ... }:

let cfg = config.cookie.ipban;

in with lib; {
  options.cookie.ipban = {
    enable = mkEnableOption "firewall IP banning module";
    ips = mkOption {
      type = types.listOf types.str;
      description = "a list of ips to ban";
      default = [
        "45.135.232.165"
        "61.177.172.158"
        "23.137.250.209"
        # https://openai.com/gptbot-ranges.txt
        "20.15.240.64/28"
        "20.15.240.80/28"
        "20.15.240.96/28"
        "20.15.240.176/28"
        "20.15.241.0/28"
        "20.15.242.128/28"
        "20.15.242.144/28"
        "20.15.242.192/28"
        "40.83.2.64/28"
        #
      ];
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.extraCommands = "${toString (concatMapStringsSep "\n"
      (v: "iptables -I INPUT -s ${escapeShellArg v} -j DROP") cfg.ips)}";
  };
}
