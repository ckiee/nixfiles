{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.chat;

in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ discord discord-ptb fractal ];
    cookie.weechat.enable = true;

    # Bump discord without bumping nixpkgs
    # nixpkgs.overlays = [
    #   (self: super: {
    #     discord = super.discord.overrideAttrs (_: {
    #       src = builtins.fetchTarball
    #         "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz";
    #     });
    #     discord-ptb = super.discord-ptb.overrideAttrs (_: {
    #       src = builtins.fetchTarball
    #         "https://dl-ptb.discordapp.net/apps/linux/0.0.25/discord-ptb-0.0.25.tar.gz";
    #     });
    #   })
    # ];
  };
}
