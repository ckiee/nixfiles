{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.comicfury;
  util = import ./util.nix margs;
in with lib; {
  # XXX This service is no longer operational. XXX
  options.cookie.services.comicfury = {
    enable = mkEnableOption "ComicFury webhook for Rain";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/comicfury";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (util.mkService "comicfury" {
    home = cfg.folder;
    description = "ComicFury discord webhook";
    secrets.env = {
      source = "./secrets/comicfury.env";
      dest = "${cfg.folder}/.env";
      permissions = "0400";
    };
    script = let cf = pkgs.cookie.comicfury-discord-webhook;
    in ''
      ln -sf ${cf}/libexec/comicfury-discord-webhook/deps/comicfury-discord-webhook/.env.example
      exec ${cf}/bin/comicfury-discord-webhook
    '';
  });
}
