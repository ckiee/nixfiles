# This is based off of https://github.com/nix-community/nur-combined/blob/2807de75e8b23f68c6d3a6c1bdce5ae4140ae16d/repos/noneucat/pkgs/immersed/default.nix, LICENSE can be found there.
{ makeDesktopItem, stdenv, lib, wrapGAppsHook, autoPatchelfHook, fetchurl
, ffmpeg-full, p7zip, gtk3, gdk-pixbuf, glib, pango, cairo, fontconfig, libva
, xorg, zlib, glibc, libpulseaudio, libGL, libvaDriverName ? "iHD" }:
let
  desktopItem = makeDesktopItem {
    name = "immersed";
    exec = "Immersed";
    icon = "Immersed";
    desktopName = "Immersed";
    genericName = "Immersed VR Agent";
  };
in stdenv.mkDerivation {
  pname = "Immersed";
  version = "6"; # The version number is hidden in the logs.

  src = fetchurl {
    url = "https://immersedvr.com/dl/Immersed-x86_64.AppImage";
    sha256 = "0yfslpjfxc5iqk5sb52l8jv6fgam8z2bik7brj3hki0q4wfyrzlb";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook p7zip ];

  buildInputs = [
    libpulseaudio
    gtk3
    pango
    gdk-pixbuf
    glib
    fontconfig
    cairo
    zlib
    glibc
    libva
    libGL

    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libSM
  ];

  unpackPhase = ''
    7z x $src
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/va2

    install -Dm755 usr/bin/Immersed $out/bin/Immersed

    # ln -s ${desktopItem}/share/applications/* $out/share/applications

    ln -s ${ffmpeg-full}/lib/libavcodec.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavdevice.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavfilter.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavformat.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavutil.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libswresample.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libswscale.so $out/lib/va2
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      --set-default LIBVA_DRIVER_NAME ${libvaDriverName}
    )
  '';

  meta = {
    description = "Immersed VR agent for Linux";
    homepage = "https://immersedvr.com/";
    downloadPage = "https://immersedvr.com/dl/Immersed-x86_64.AppImage";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.noneucat ];
    platforms = [ "x86_64-linux" ];
  };
}
