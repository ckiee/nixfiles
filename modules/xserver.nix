{ lib, config, pkgs, ... }:

let cfg = config.cookie.xserver;
in with lib; {
  options.cookie.xserver = {
    enable = mkEnableOption "Enables the X11 server";
  };
  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
      desktopManager.xterm.enable =
        true; # this somehow makes home-manager's stuff run
    };
  };
}
