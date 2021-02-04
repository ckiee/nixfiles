{ config, pkgs, ... }: {

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      # nerdfonts
      hack-font
      ubuntu_font_family
      corefonts
      # google-fonts # this kills doom emacs performance for some reason
      proggyfonts
      cantarell-fonts
      material-design-icons
      weather-icons
      font-awesome
      emacs-all-the-icons-fonts
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Hack" ];
        sansSerif = [ "Cantarell" ];
        # serif is ew
      };
      # hinting.autohint = true;
      # subpixel.lcdfilter = "none";
    };
  };
}
