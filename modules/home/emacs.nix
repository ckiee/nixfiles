{ lib, config, pkgs, ... }:

let
  emacs-overlay = (builtins.fetchGit {
    url = "https://github.com/nix-community/emacs-overlay.git";
    rev = "65c012a5e031c94c7c42c626451eaed9c4215fe8";
    ref = "master";
  });
  exs-emacsclient =
    pkgs.writeTextFile { # theres a special helper for .desktop entries but i'm lazy and this works!
      name = "emacsclientexs.desktop";
      destination = "/share/applications/emacsclientexs.desktop";
      text = ''
        [Desktop Entry]
        Name=Emacs (Open in existing window)
        GenericName=Text Editor
        Comment=Edit text
        MimeType=inode/directory;text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
        Exec=emacsclient -n %F
        Icon=emacs
        Type=Application
        Terminal=false
        Categories=Development;TextEditor;
        StartupWMClass=Emacsd
        Keywords=Text;Editor;
      '';
    };
  cfg = config.cookie.emacs;
in with lib; {

  options.cookie.emacs = { enable = mkEnableOption "Enables DOOM Emacs"; };
  config = mkIf cfg.enable {

    nixpkgs.overlays = [ (import emacs-overlay) ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacsGcc;
    };

    home.file.".doom.d".source = ../../ext/doom-conf;
    # we cant just symlink bc doom binary wants to mutate ~/.emacs.d
    # this seems to break, just git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d && doom sync
    home.activation = {
      doomEmacs = ''
        #  if [[ ! -d ~/.emacs.d ]]; then
        #    git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d
        #  fi
        # ~/.emacs.d/bin/doom sync
      '';
    };

    home.sessionPath = [ "~/.emacs.d/bin" ];

    # doom emacs wants these
    home.packages = with pkgs; [
      shellcheck
      ripgrep
      jq
      fd
      jdk11
      rust-analyzer-unwrapped
      rnix-lsp
      nixfmt
      exs-emacsclient
      shfmt
      ccls
      python3Packages.black
      ispell
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      editorconfig-core-c
    ];
  };
}
