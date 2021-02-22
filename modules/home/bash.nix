{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      rsync = "rsync --progress";
      ls =
        "ls --color=auto --human-readable --group-directories-first --classify";
      nsp = "nix-shell -p ";
    };
    sessionVariables = {
      VISUAL = "nano";
      EDITOR = "nano";
    };
    # interactive shell only: 
    initExtra = ''
      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
        DISPLAY=:0 which notify-send > /dev/null 2>&1 && notify-send ssh "$SSH_CLIENT connected"
      fi 

      PS1="\[\e[36m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\] \w -> "
      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        PS1="(ssh) $PS1"
      fi

      export TERM=xterm-256color
    '';
  };
}
