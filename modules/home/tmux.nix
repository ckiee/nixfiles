{ lib, config, pkgs, ... }:

let cfg = config.cookie.tmux;

in with lib; {
  options.cookie.tmux = {
    enable = mkEnableOption "Enables tmux";
    taboo.enable = mkEnableOption "Enables taboo";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      escapeTime = 20;
    };
    programs.bash.initExtra = mkIf cfg.taboo.enable ''
      function tmux_taboo {
        local dir="$XDG_RUNTIME_DIR/tmux-taboo"
        local port="''${$:-TMUX_TABOO_ID}"
        local win="auto$(tmux list-sessions 2>/dev/null | rg auto- | wc -l)"
        if [[ -z "$TMUX" ]]; then
          mkdir -p "$dir"
          touch "$dir/$port"
          local new_win="auto$(( 1 + "$(tmux list-sessions 2>/dev/null | rg auto- | wc -l)" ))"

          # try to attach to an unattached session or make a new session+window pair
          if ! tmux attach-session -t $(tmux list-sessions | rg -v '\(attached\)' | rg '(.+?):.+' --replace '$1' | head -n1) > /dev/null; then
            tmux new-window -dan "$new_win" &>/dev/null
            tmux new-session -tauto -d && tmux select-window -t "$new_win" &>/dev/null
            tmux attach-session
          fi


          rm "$dir/$port"
          read -t 1 -p "[hit return for shell]"
          [ "$?" -ne 0 ] && echo && exit
        else
          if ! tmux list-windows -F '#{window_active} #{window_name}' | rg '^1 auto' >/dev/null; then
            tmux rename-window "$win"
          fi
        fi
      }
      if [ -n "$SSH_CLIENT" ]; then
        tmux_taboo
      fi
      alias tab="tmux_taboo"
    '';
  };
}
