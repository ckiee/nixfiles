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
        vlc = "vlc.desktop";
        audacity = "audacity.desktop";
        nautilus = "org.gnome.Nautilus.desktop";
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
        "text/x-sh" = [ emacs ];
        "application/x-java-archive" = [ "org.gnome.FileRoller.desktop" ];
        "text/x-lisp" = [ emacs ];
        "image/png" = [ "feh.desktop" ];
        "application/xml" = [ emacs ];
        "video/x-matroska" = [ mpv ];
        "application/octet-stream" = [ emacs ];
        "audio/mp4" = [ mpv ];
        "binary/octet-stream" = [ emacs ];
        "audio/flac" = [ mpv ];
        "video/x-msvideo" = [ mpv ];
        "audio/mpeg" = [ mpv vlc audacity ];
        "audio/x-vorbis+ogg" = [ audacity vlc mpv ];
        "audio/x-wav" = [ mpv ];
        "video/quicktime" = [ mpv ];
        "inode/directory" = [ nautilus ]; # folders!
        "application/vnd.mozilla.xul+xml" = [ firefox ];
        "x-scheme-handler/http" = [ firefox ];
        "x-scheme-handler/https" = [ firefox ];
        "text/csv" = [ emacs ];
      };
    };

    xdg.configFile."mimeapps.list".force = true;
  };
}
