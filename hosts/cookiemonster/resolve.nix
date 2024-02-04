{ config, lib, pkgs, ... }:

{

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    distrobox

    (makeDesktopItem {
      name = "resolve";
      exec = pkgs.writeShellScriptBin "resolve-db-wrapped" ''
        xauth add "resolve.$(hostname)/unix$DISPLAY" . "$(xauth list | grep "^$(hostname)/unix$DISPLAY\s*MIT-MAGIC-COOKIE-1\s*" | awk '{print $3}')"
        exec distrobox enter resolve -- /opt/resolve/bin/resolve
      '';
      icon = "resolve";
      desktopName = "DaVinci Resolve";
    })
  ];
  # DaVinci_Resolve_18.6.4_Linux.zip
  # distrobox-create --name resolve --image fedora:37
  # sudo dnf install -y alsa-plugins-pulseaudio libxcrypt-compat xcb-util-renderutil xcb-util-wm pulseaudio-libs xcb-util xcb-util-image xcb-util-keysyms libxkbcommon-x11 libXrandr libXtst mesa-libGLU mtdev libSM libXcursor libXi libXinerama libxkbcommon libglvnd-egl libglvnd-glx libglvnd-opengl libICE librsvg2 libSM libX11 libXcursor libXext libXfixes libXi libXinerama libxkbcommon libxkbcommon-x11 libXrandr libXrender libXtst libXxf86vm mesa-libGLU mtdev pulseaudio-libs xcb-util alsa-lib apr apr-util fontconfig freetype libglvnd fuse-libs"
  # sudo dnf install -y rocm-opencl
  # sudo ./*.run -i
  # /opt/resolve/bin/resolve
  #
  # install a fedora:38 and install those deps and copy all of these over:
  # /lib64/libGL.so.1      /lib64/libGLdispatch.so.0      /lib64/libGLU.so.1      /lib64/libGLX.so.0      /lib64/libGLX_mesa.so.0      /lib64/libGLX_system.so.0  /lib64/libLLVM-16.so    /lib64/libsensors.so.4.5.0 /lib64/libGL.so.1.7.0  /lib64/libGLdispatch.so.0.0.0  /lib64/libGLU.so.1.3.1  /lib64/libGLX.so.0.0.0  /lib64/libGLX_mesa.so.0.0.0  /lib64/libLLVM-16.0.6.so   /lib64/libsensors.so.4


  # https://www.youtube.com/watch?v=wmRiZQ9IZfc

  cookie.user.extraGroups = ["render"];
}
