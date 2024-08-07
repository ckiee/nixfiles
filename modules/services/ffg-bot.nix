{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.ffg-bot;
  util = import ./util.nix margs;
in with lib; {
  options.cookie.services.ffg-bot = {
    enable = mkEnableOption "Falling From Grace discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/ffg-bot";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "ffg-bot" {
      home = cfg.folder;
      description = "Falling From Grace discord bot";
      secrets.env = {
        source = "./secrets/ffg-bot.env";
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      requires = [ "postgresql.service" ];
      script = let ffg = pkgs.cookie.ffg-bot;
      in ''
        # Does not support UNIX sockets apparently..
        export DB_URL="postgres://ffgbot@127.0.0.1:5432/ffgbot"
        ln -sf ${ffg}/libexec/ffg-bot/deps/ffg-bot/.env.example .env.example
        exec ${ffg}/bin/ffg-bot
      '';
    })
    {
      cookie.services.postgres = {
        enable = true;
        comb.ffgbot = { networkTrusted = true; };
      };
    }
  ]);
}
