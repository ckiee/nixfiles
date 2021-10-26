{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.chat;

in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (discord-ptb.overrideAttrs (_: {
        src = builtins.fetchTarball
          "https://dl-ptb.discordapp.net/apps/linux/0.0.26/discord-ptb-0.0.26.tar.gz";
      }))
      (discord.overrideAttrs (_: {
        src = builtins.fetchTarball
          "https://dl.discordapp.net/apps/linux/0.0.16/discord-0.0.16.tar.gz";
      }))
      fractal
      mirage-im
    ];
    cookie.weechat.enable = true;
  };
}
