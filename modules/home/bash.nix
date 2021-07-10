{ config, lib, pkgs, ... }:

let cfg = config.cookie.bash;
in with lib; {

  options.cookie.bash = {
    enable = mkEnableOption "Enables the Bash shell and Direnv";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = {
        ls = "${pkgs.exa}/bin/exa";
        cd = "z";
        rsync = "rsync --progress";
        nsp = "nix-shell -p";
        ns = "nix search nixpkgs";
        e = "emacsclient -n";
        cl = "clear"; # I am too used to WeeChat
        ytm =
          "${pkgs.youtube-dl}/bin/youtube-dl -f 140 --add-metadata -o '~/Music/flat/%(playlist_index)s %(title)s.%(ext)s'";
      };
      sessionVariables = rec {
        EDITOR = "vim";
        VISUAL = EDITOR;
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

        ggi() {
              wget --no-verbose -O .gitignore "https://raw.githubusercontent.com/github/gitignore/master/$1.gitignore"
        }
        # Upload a file to i.ckie.dev (bokkusu)
        bokup() {
          tfn=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 7).''${1##*.}
          rsync $1 bokkusu:/var/lib/rtc-files/ckiedev/"$tfn"
          echo https://i.ckie.dev/"$tfn"
          echo https://i.ckie.dev/"$tfn" | xclip -selection c
        }
      '';
    };
    services.lorri.enable = true;
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
