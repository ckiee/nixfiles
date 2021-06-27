{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.cookie.doom-emacs;
  extraBins = with pkgs; [
    ripgrep # for +default/search-project
    jq # JSON
    fd # ...like find!
    jdk11 # Java
    rust-analyzer-unwrapped # Rust
    nixfmt # Nix
    nixpkgs-fmt # Nixpkgs
    editorconfig-core-c # editorconfig
    omnisharp-roslyn # C#
    texlive.combined.scheme-medium # org-mode latex preview
    gopls # Go LSP
    ccls # C/C++
    python3Packages.black # Python formatter
    #
    # shell scripts
    shfmt
    shellcheck
    #
    # spellcheck
    ispell
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    #
    # e-mail
    mu
    isync
  ];
  extra-desktop =
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
  sources = import ../../nix/sources.nix;
  doom-emacs = pkgs.callPackage sources.doom-emacs {
    doomPrivateDir = ../../ext/doom-conf;
    extraPackages = epkgs: [ pkgs.mu ]; # for mu4e, the email machine
    extraConfig = ''
      (setq exec-path (append exec-path '( ${
        concatMapStringsSep " " (x: ''"${x}/bin"'') extraBins
      } )))
      (setenv "PATH" (concat (getenv "PATH") ":${
        concatMapStringsSep ":" (x: "${x}/bin") extraBins
      }"))
    '';
  };
in {
  options.cookie.doom-emacs = {
    enable = mkEnableOption "Enables the Nixified Doom Emacs";
  };

  config = mkIf cfg.enable {
    home.packages = [ doom-emacs extra-desktop ];
    home.file.".emacs.d/init.el".text = ''
      (load "default.el")
    '';
    cookie.mail-client.enable = true; # Emacs needs this for mu4e, the e-mail frontend
  };
}
