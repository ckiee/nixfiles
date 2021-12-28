{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.alvr-bot;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.alvr-bot = {
    enable = mkEnableOption "Enables the ALVR discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/alvr-bot";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "alvr-bot" {
      home = cfg.folder;
      description = "alvr-bot";
      secrets.env = {
        source = "./secrets/alvr-bot.env";
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      script = let bin = pkgs.cookie.alvr-bot;
      in ''
        ln -sf ${bin}/libexec/alvr-bot/deps/alvr-bot/.env.example .env.example
        exec ${bin}/bin/alvr-bot
      '';
    })
  ]);
}
