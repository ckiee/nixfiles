{ lib, config, pkgs, ... }:

let cfg = config.cookie.chat-apps;
in with lib; {
  options.cookie.chat-apps = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
      discord-ptb
      weechat
    ];
  };
}
