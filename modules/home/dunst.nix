{ ... }:

let
  normal_urgencies = {
    background = "#212121";
    foregrund = "#ffffff";
    timeout = 10;
  };

in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        geometry = "300x100-30+20";
        frame_color = "#212121";
        font = "Monospace 10";
        format = "<b>%a</b>: %s\\n%b";
        show_indicators = false;
        shrink = false;
        alignment = "center";
        padding = 8;
        word_wrap = true;
        seperator_height = 0;
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
      urgency_low = normal_urgencies;
      urgency_normal = normal_urgencies;
      urgency_critical = {
        background = "#ff1744";
        foregrund = "#fffff";
        timeout = 60;
      };
    };
  };
}
