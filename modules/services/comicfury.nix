{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.comicfury;
  util = import ./util.nix { inherit lib config; };
  service = util.mkService "comicfury" {
    home = "/cookie/comicfury";
    description = "ComicFury discord webhook";
    secrets.env = {
      source = ../../secrets/comicfury-env;
      dest = "/cookie/comicfury/.env";
      permissions = "0400";
    };
    script = let cf = pkgs.cookie.comicfury-discord-webhook;
    in ''
      rm .env.example || true
      ln -s ${cf}/libexec/comicfury-discord-webhook/deps/comicfury-discord-webhook/.env.example || true
      exec ${cf}/bin/comicfury-discord-webhook
    '';
  };
in with lib; {
  options.cookie.services.comicfury = {
    enable = mkEnableOption "Enables the ComicFury webhook for Rain";
  };

  config = mkIf cfg.enable service;
}
