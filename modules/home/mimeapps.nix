{ lib, config, pkgs, ... }:

let cfg = config.cookie.mimeapps;

in with lib; {
  options.cookie.mimeapps = {
    enable = mkEnableOption "Enables MIME file association configuration";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        emacs = "emacsclientexs.desktop";
        firefox = "firefox.desktop";
        mpv = "mpv.desktop";
      in {
        "application/pdf" = [ firefox ];
        "text/plain" = [ emacs ];
        "text/x-java" = [ emacs ];
        "text/html" = [ emacs ];
        "application/xhtml+xml" = [ emacs ];
        "text/yaml" = [ emacs ];
        "text/x-c++src" = [ emacs ];
        "x-scheme-handler/magnet" =
          [ "userapp-transmission-gtk-29NL20.desktop" ];
        "text/x-csrc" = [ emacs ];
        "audio/x-vorbis+ogg" = [ "audacity.desktop" "vlc.desktop" mpv ];
        "audio/mpeg" = [ mpv "vlc.desktop" "audacity.desktop" ];
        "text/x-sh" = [ emacs ];
        "application/x-java-archive" = [ "org.gnome.FileRoller.desktop" ];
        "text/x-lisp" = [ emacs ];
        "image/png" = [ "feh.desktop" ];
        "video/mp4" = [ "vlc.desktop" mpv ];
        "application/xml" = [ emacs ];
        "video/quicktime" = [ mpv ];
        "audio/x-wav" = [ mpv ];
        "video/x-matroska" = [ mpv ];
        "application/octet-stream" = [ emacs ];
        "audio/mp4" = [ mpv ];
        "binary/octet-stream" = [ emacs ];
        "audio/flac" = [ mpv ];
      };
    };
  };
}
