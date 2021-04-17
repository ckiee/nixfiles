{ config, lib, pkgs, ... }:

let cfg = config.cookie.desktop;
in with lib; {
  options.cookie.desktop = {
    enable = mkEnableOption "Enables the Cookie's desktop";
  };

  config = mkIf cfg.enable {
    home-manager.users.ron = { pkgs, ... }: {
      cookie = {
        polybar = { enable = true; };
        gtk.enable = true;
        dunst.enable = true;
        emacs.enable = true;
        keyboard.enable = true;
        redshift.enable = true;
        st.enable = true;
        nautilus.enable = true;
        i3.enable = true;
        xcursor.enable = true;
      };
    };
    cookie = {
      xserver.enable = true;
      sound.enable = true;
      sleep.enable = true;
      slock.enable = true;
      fonts.enable = true;
      gnome.enable = true;
    };
  };
}
