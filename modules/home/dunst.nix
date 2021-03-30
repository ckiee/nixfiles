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
        indicate_hidden = true;
        shrink = false;
        transperency = 0;
        notification_height = 0;
        seperator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 0;
        seperator_color = "frame";
        sort = true;
        idle_threshold = 120;
        font = "Monospace 10";
        line_height = 0;
        markup = "full";
        format = "<b>%a</b>: %s\\n%b";
        alignment = "center";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = false;
        icon_position = "off";
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
