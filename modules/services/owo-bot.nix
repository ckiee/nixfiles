{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.owo-bot;
  util = import ./util.nix { inherit lib config; };
  service = util.mkService "owo-bot" {
    home = "/cookie/owo-bot";
    description = "OwOifying discord bot";
    secrets.env = {
      source = ../../secrets/owo-bot.env;
      dest = "/cookie/owo-bot/.env";
      permissions = "0400";
    };
    script = let owo = pkgs.cookie.owo-bot;
    in ''
      ln -sf ${owo}/libexec/owo-bot/deps/owo-bot/.env.example .env.example
      exec ${owo}/bin/owo-bot
    '';
  };
in with lib; {
  options.cookie.services.owo-bot = {
    enable = mkEnableOption "Enables the OwOifying discord bot";
  };

  config = mkIf cfg.enable service;
}
