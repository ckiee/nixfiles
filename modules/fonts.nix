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
      source-sans-pro
      jetbrains-mono
      inter
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono" ];
        sansSerif = [ "Inter" ];
        # serif is ew
      };
      localConf = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <description>Disable ligatures for monospaced fonts</description>

          <match target="font">
            <test name="family" compare="eq" ignore-blanks="true">
              <string>JetBrains Mono</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <string>liga off</string>
              <string>dlig off</string>
              <string>calt off</string>
              <string>clig off</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };
}
