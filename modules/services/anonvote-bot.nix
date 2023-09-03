{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.anonvote-bot;
  util = import ./util.nix margs;
in with lib; {
  options.cookie.services.anonvote-bot = {
    enable = mkEnableOption "anonvote-bot discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/anonvote-bot";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "anonvote-bot" {
      home = cfg.folder;
      description = "anonvote-bot discord bot";
      secrets.env = {
        source = "./secrets/anonvote-bot.env";
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      script = let bin = pkgs.cookie.anonvote-bot;
      in ''
        ln -sf ${bin}/libexec/anonvote-bot/deps/anonvote-bot/.env.example .env.example
        exec ${bin}/bin/anonvote-bot
      '';
    })
  ]);
}
