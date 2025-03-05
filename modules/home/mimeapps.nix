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
        audacity = "audacity.desktop";
        nemo = "nemo.desktop";
        eog = "org.gnome.eog.desktop";
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
        "image/bmp" = [ eog ];
        "image/gif" = [ eog ];
        "image/jpeg" = [ eog ];
        "image/jpg" = [ eog ];
        "image/pjpeg" = [ eog ];
        "image/png" = [ eog ];
        "image/tiff" = [ eog ];
        "image/webp" = [ eog ];
        "image/x-bmp" = [ eog ];
        "image/x-gray" = [ eog ];
        "image/x-icb" = [ eog ];
        "image/x-ico" = [ eog ];
        "image/x-png" = [ eog ];
        "image/x-portable-anymap" = [ eog ];
        "image/x-portable-bitmap" = [ eog ];
        "image/x-portable-graymap" = [ eog ];
        "image/x-portable-pixmap" = [ eog ];
        "image/x-xbitmap" = [ eog ];
        "image/x-xpixmap" = [ eog ];
        "image/x-pcx" = [ eog ];
        "image/svg+xml" = [ eog ];
        "image/svg+xml-compressed" = [ eog ];
        "image/vnd.wap.wbmp" = [ eog ];
        "image/x-icns" = [ eog ];
        "application/xml" = [ emacs ];
        "video/x-matroska" = [ mpv ];
        "application/octet-stream" = [ emacs ];
        "audio/mp4" = [ mpv ];
        "binary/octet-stream" = [ emacs ];
        "audio/flac" = [ mpv ];
        "video/x-msvideo" = [ mpv ];
        "audio/mpeg" = [ mpv audacity ];
        "audio/x-vorbis+ogg" = [ audacity mpv ];
        "audio/x-wav" = [ mpv ];
        "video/quicktime" = [ mpv ];
        "inode/directory" = [ nemo ]; # folders!
        "application/vnd.mozilla.xul+xml" = [ firefox ];
        "x-scheme-handler/http" = [ firefox ];
        "x-scheme-handler/https" = [ firefox ];
        "text/csv" = [ emacs ];
      };
    };

    xdg.configFile."mimeapps.list".force = true;
  };
}
