{ lib, config, pkgs, ... }:

let cfg = config.cookie.mangohud;

in with lib; {
  options.cookie.mangohud = {
    enable = mkEnableOption "Enables mangohud";
  };

  config = mkIf cfg.enable {
    # This may be my shortest module in this repo
    programs.mangohud.enable = true;
  };
}
