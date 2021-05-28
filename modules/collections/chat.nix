{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.collections.chat;

  # https://github.com/xe/nixos-configs/commit/36fc81b#diff-8f732ff9aa6533343d2b0f42228f4091570a67c74472a2dce97786f89407d07dR83
  weechat = with pkgs.weechatScripts;
    pkgs.weechat.override {
      configure = { availablePlugins, ... }: {
        scripts = [ weechat-autosort ];
      };
    };
in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord discord-ptb weechat ];

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
