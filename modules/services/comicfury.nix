{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.comicfury;
  util = import ./util.nix { inherit lib config; };
  service = util.mkService "comicfury" {
    home = "/cookie/comicfury";
    description = "ComicFury discord webhook";
    script = let cf = pkgs.cookie.comicfury-discord-webhook;
    in ''
      ln -s ${cf}/deps/comicfury-discord-webhook/.env.example .env.example || true
      exec ${cf}/bin/comicfury-discord-webhook'';
  };
in with lib; {
  options.cookie.services.comicfury = {
    enable = mkEnableOption "Enables the ComicFury webhook for Rain";
  };

  config = mkIf cfg.enable service;
}
