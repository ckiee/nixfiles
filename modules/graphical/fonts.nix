{ config, pkgs, ... }: {

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      cantarell-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      nerdfonts
      hack-font
      ubuntu_font_family
      corefonts
      roboto
      roboto-mono
      # google-fonts # this kills doom emacs performance for some reason
      proggyfonts
      roboto-slab
      cantarell-fonts
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Hack" ];
      sansSerif = [ "Cantarell" ];
      # serif is ew
    };
  };
}
