{ lib, config, pkgs, ... }:

let cfg = config.cookie.fonts;
in with lib; {
  options.cookie.fonts = {
    enable = mkEnableOption "Enables a collection of fonts";
  };

  config.fonts = mkIf cfg.enable {

    enableDefaultFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      hack-font
      ubuntu_font_family
      corefonts
      # google-fonts # this kills doom emacs performance for some reason. Do not use.
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
    };
  };
}
