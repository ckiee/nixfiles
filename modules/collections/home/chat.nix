{ lib, config, pkgs, nixosConfig, ... }:

let cfg = config.cookie.collections.chat;

in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      discord-ptb
      # fractal
      (element-desktop.override { element-web = nixosConfig.cookie.services.matrix.elementRoot; })
    ];
    cookie.weechat.enable = true;
  };
}
