{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.ffg-bot;
  util = import ./util.nix { inherit lib config; };
  service = util.mkService "ffg-bot" {
    home = "/cookie/ffg-bot";
    description = "Falling From Grace discord bot";
    secrets.env = {
      source = ../../secrets/ffg-bot.env;
      dest = "/cookie/ffg-bot/.env";
      permissions = "0400";
    };
    wants = [ "postgresql.service" ];
    script = let ffg = pkgs.cookie.ffg-bot;
    in ''
      export DB_URL="postgres://ffgbot@localhost:5432/ffgbot"
      ln -sf ${ffg}/libexec/ffg-bot/deps/ffg-bot/.env.example .env.example
      exec ${ffg}/bin/ffg-bot
    '';
  };
in with lib; {
  options.cookie.services.ffg-bot = {
    enable = mkEnableOption "Enables the Falling From Grace discord bot";
  };

  config = mkIf cfg.enable (mkMerge [
    service
    {
      cookie.services.postgres = {
        enable = true;
        combs = [ "ffgbot" ];
      };
    }
  ]);
}
