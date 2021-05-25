{ lib, config, pkgs, ... }:

let cfg = config.cookie.chat-apps;
in with lib; {
  options.cookie.chat-apps = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord discord-ptb weechat ];

    # Bump discord without bumping nixpkgs
    nixpkgs.overlays = [
      (self: super: {
        discord = super.discord.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz";
        });
        discord-ptb = super.discord-ptb.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://dl-ptb.discordapp.net/apps/linux/0.0.25/discord-ptb-0.0.25.tar.gz";
        });
      })
    ];
  };
}
