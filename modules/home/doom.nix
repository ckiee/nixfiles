{ pkgs, ... }:

let
  emacs-overlay = (builtins.fetchGit {
    url = "https://github.com/nix-community/emacs-overlay.git";
    rev = "dcb4f8e97b3a6f215e8a30bc01028fc67a4015e7";
    ref = "master";
  });
  ron-emacsclient =
    pkgs.writeTextFile { # theres a special helper for .desktop entries but i'm lazy and this works!
      name = "emacsclientron.desktop";
      destination = "/share/applications/emacsclientron.desktop";
      text = ''
        [Desktop Entry]
        Name=Emacs Client
        GenericName=Text Editor
        Comment=Edit text
        MimeType=inode/directory;text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
        Exec=emacsclient -n %F
        Icon=emacs
        Type=Application
        Terminal=false
        Categories=Development;TextEditor;
        StartupWMClass=Emacs
        Keywords=Text;Editor;
      '';
    };
in {
  nixpkgs.overlays = [ (import emacs-overlay) ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacsGcc;
    # extraPackages = epkgs: [ epkgs.vterm ];
  };

  home.file.".doom.d".source = ./doom-conf;
  # we cant just symlink bc stupid doom binary wants to mutate ~/.emacs.d
  # this seems to break, just git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d && doom sync
  home.activation = {
    doomEmacs = ''
            if [[ ! -d ~/.emacs.d ]]; then
              git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d
            fi
      #      ~/.emacs.d/bin/doom sync
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
    ron-emacsclient
    shfmt
    ccls
    python3Packages.black
    ispell
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    editorconfig-core-c
  ];

}
