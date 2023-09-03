{ lib, config, pkgs, ... }:

let cfg = config.cookie.wireshark;

in with lib; {
  options.cookie.wireshark = {
    enable = mkEnableOption "wireshark network-monitoring program";
  };

  config = mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };

    users.users.ckie.extraGroups = [ "wireshark" ];
  };
}
