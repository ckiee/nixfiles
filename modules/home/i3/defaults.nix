{ cfg, ... }:

{
  "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
  "${cfg.config.modifier}+Shift+q" = "kill";
  "${cfg.config.modifier}+d" = "exec ${cfg.config.menu}";

  "${cfg.config.modifier}+Left" = "focus left";
  "${cfg.config.modifier}+Down" = "focus down";
  "${cfg.config.modifier}+Up" = "focus up";
  "${cfg.config.modifier}+Right" = "focus right";

  "${cfg.config.modifier}+Shift+Left" = "move left";
  "${cfg.config.modifier}+Shift+Down" = "move down";
  "${cfg.config.modifier}+Shift+Up" = "move up";
  "${cfg.config.modifier}+Shift+Right" = "move right";

  "${cfg.config.modifier}+h" = "split h";
  "${cfg.config.modifier}+v" = "split v";
  "${cfg.config.modifier}+f" = "fullscreen toggle";

  "${cfg.config.modifier}+s" = "layout stacking";
  # "${cfg.config.modifier}+w" = "layout tabbed";
  "${cfg.config.modifier}+e" = "layout toggle split";

  "${cfg.config.modifier}+Shift+space" = "floating toggle";
  "${cfg.config.modifier}+space" = "focus mode_toggle";

  # "${cfg.config.modifier}+a" = "focus parent";

  "${cfg.config.modifier}+Shift+minus" = "move scratchpad";
  "${cfg.config.modifier}+minus" = "scratchpad show";

  "${cfg.config.modifier}+1" = "workspace number 1";
  "${cfg.config.modifier}+2" = "workspace number 2";
  "${cfg.config.modifier}+3" = "workspace number 3";
  "${cfg.config.modifier}+4" = "workspace number 4";
  "${cfg.config.modifier}+5" = "workspace number 5";
  "${cfg.config.modifier}+6" = "workspace number 6";
  "${cfg.config.modifier}+7" = "workspace number 7";
  "${cfg.config.modifier}+8" = "workspace number 8";
  "${cfg.config.modifier}+9" = "workspace number 9";
  "${cfg.config.modifier}+0" = "workspace number 10";

  "${cfg.config.modifier}+Shift+1" = "move container to workspace number 1";
  "${cfg.config.modifier}+Shift+2" = "move container to workspace number 2";
  "${cfg.config.modifier}+Shift+3" = "move container to workspace number 3";
  "${cfg.config.modifier}+Shift+4" = "move container to workspace number 4";
  "${cfg.config.modifier}+Shift+5" = "move container to workspace number 5";
  "${cfg.config.modifier}+Shift+6" = "move container to workspace number 6";
  "${cfg.config.modifier}+Shift+7" = "move container to workspace number 7";
  "${cfg.config.modifier}+Shift+8" = "move container to workspace number 8";
  "${cfg.config.modifier}+Shift+9" = "move container to workspace number 9";
  "${cfg.config.modifier}+Shift+0" = "move container to workspace number 10";

  "${cfg.config.modifier}+Shift+c" = "reload";
  "${cfg.config.modifier}+Shift+r" = "restart";
  "${cfg.config.modifier}+Shift+e" =
    "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

  "${cfg.config.modifier}+r" = "mode resize";
}
