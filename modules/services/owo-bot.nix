{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.owo-bot;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.owo-bot = {
    enable = mkEnableOption "Enables the OwOifying discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/owo-bot";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "owo-bot" {
      home = cfg.folder;
      description = "OwOifying discord bot";
      secrets.env = {
        source = ../../secrets/owo-bot.env;
        dest = "${cfg.folder}/.env";
        permissions = "0400";
      };
      script = let owo = pkgs.cookie.owo-bot;
      in ''
        export MONGO_URL=mongodb://localhost:27017/
        export MONGO_DB=owo-bot
        ln -sf ${owo}/libexec/owo-bot/deps/owo-bot/.env.example .env.example
        exec ${owo}/bin/owo-bot
      '';
    })
    {
      services.mongodb.enable = true;
    }
  ]);
}
