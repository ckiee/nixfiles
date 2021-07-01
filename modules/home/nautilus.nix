{ lib, config, pkgs, nixosConfig, ... }:

let cfg = config.cookie.nautilus;
in with lib; {
  options.cookie.nautilus = {
    enable = mkEnableOption "Enables forcing of some Nautilus preferences";
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = nixosConfig.programs.dconf.enable;
      message = "dconf must be enabled in the system configuration";
    }];
    dconf.settings."org/gnome/nautilus/preferences" = {
      default-sort-in-reverse-order = true;
      default-sort-order = "mtime";
    };
    home.packages = with pkgs; [
      gnome3.nautilus
      gnome3.gvfs # nautilus likes this!
    ];
  };
}
