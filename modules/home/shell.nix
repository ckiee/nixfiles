{ config, lib, pkgs, ... }:

let cfg = config.cookie.shell;
in with lib; {

  options.cookie.shell = {
    enable = mkEnableOption "Enables the generic shell configuration";
    bash = mkEnableOption "Enables the Bash shell configuration";
    fish = mkEnableOption "Enables the Fish shell configuration";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.lorri.enable = true;
      programs = {
        exa.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableBashIntegration = cfg.bash;
        };
        zoxide = {
          enable = true;
          enableBashIntegration = cfg.bash;
          enableFishIntegration = cfg.fish;
        };
        nix-index =
          { # provides a command-not-found binary to replace the one we broke
            enable = true;
            enableBashIntegration = cfg.bash;
            enableFishIntegration = cfg.fish;
          };
      };
    }

    (mkIf cfg.bash {
      programs.bash = {
        enable = true;
        shellAliases = {
          ls = "${pkgs.exa}/bin/exa";
          cd = "z";
          rsync = "rsync --progress";
          nsp = "nix-shell -p";
          ns = "nix search nixpkgs";
          e = "emacsclient -n";
          ytm =
            "${pkgs.yt-dlp}/bin/yt-dlp -f 140 --add-metadata -o '~/Music/flat/%(playlist_index)s %(title)s.%(ext)s'";
          rgbc =
            "printf 'xffxfb%c%c%c' $(${pkgs.gnome.zenity}/bin/zenity --color-selection | cut -d'(' -f2 | cut -d')' -f1 | tr ',' ' ') | ${pkgs.picocom}/bin/picocom -qrb 9600 /dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0";
        };
        sessionVariables = rec {
          EDITOR = "vim";
          VISUAL = EDITOR;
        };
        # interactive shell only:
        initExtra = ''
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            DISPLAY=:0 which notify-send > /dev/null 2>&1 && notify-send ssh "$SSH_CLIENT connected" &
          fi

          PS1="\[\e[36m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\] \w -> "
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            PS1="(ssh) $PS1"
          fi
        '';
      };
    })

    (mkIf cfg.fish {
      programs.fish = {
        enable = true;
        # Normal aliases like bash
        shellAliases = {
          ls = "exa";
          l = "exa -lah";
          cd = "z";
          ytm =
            "${pkgs.youtube-dl}/bin/youtube-dl -f 140 --add-metadata -o '~/Music/flat/%(playlist_index)s %(title)s.%(ext)s'";
        };
        # Aliases that expand when you type them
        shellAbbrs = {
          nsp = "nix-shell -p";
          ns = "nix search nixpkgs";
          e = "emacsclient -n";
          rsync = "rsync --progress";
          gl = "git log";
        };
        interactiveShellInit = ''
          ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
        '';

      };
    })
  ]);
}
