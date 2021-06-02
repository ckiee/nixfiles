{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.comicfury;
in with lib; {
  options.cookie.services.comicfury = {
    enable = mkEnableOption "Enables the ComicFury webhook for Rain";
  };

  config = mkIf cfg.enable
    { # TODO, reference: https://github.com/Xe/nixos-configs/blob/master/common/services/withinbot.nix
    };
}
