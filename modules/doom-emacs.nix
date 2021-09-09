{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.cookie.doom-emacs;
  # TODO: Make a nixpkgs PR when 1.6.2 hits, currently nixpkgs has 1.6.0
  # and I feel bad about making a PR just to bump for a minor semver
  # increment.
  mu = (pkgs.mu.overrideAttrs (_: rec {
    version = "1.6.4";
    src = pkgs.fetchFromGitHub {
      owner = "djcb";
      repo = "mu";
      rev = version;
      sha256 = "sha256-rRBi6bgxkVQ94wLBqVQikIE0jVkvm1fjtEzFMsQTJz8=";
    };
  }));
  extraBins = with pkgs;
    [
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
      clang # for clang-format. C(++) Formatting without the LSP
      python3Packages.black # Python formatter
      html-tidy # HTML/SVG/Web formatter
      pandoc # markdown previewing (SPC m p in markdown-mode)
      elmPackages.elm # Elm
      elmPackages.elm-format # Elm
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
      isync
    ] ++ singleton mu; # ensure we get the overriden version
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
  sources = import ../nix/sources.nix;
  doom-emacs = let
    overridenEmacs = pkgs.emacs.override {
      withXwidgets = true;
      withGTK3 = true;
    };
  in pkgs.callPackage sources.doom-emacs {
    doomPrivateDir = ../ext/doom-conf;
    extraPackages = epkgs: [
      mu

    ];
    emacsPackages = pkgs.emacsPackagesFor overridenEmacs;
    emacsPackagesOverlay = prev: final: {
      mcf-mode = (prev.trivialBuild {
        pname = "mcf-mode";
        version = "git";

        src = pkgs.fetchFromGitHub {
          owner = "rasensuihei";
          repo = "mcf";
          rev = "4e44b6e24d9fe7a4ce7249df79f4473c0b473232";
          sha256 = "sha256-2pwP3/rnADDfkJYOal2bp9vVYoXdvC5V0ZCeHYDsExk=";
        };

        meta = {
          description = "Emacs major mode for editing Minecraft mcfunction";
          license = licenses.gpl3Plus;
          homepage = "https://github.com/rasensuihei/mcf";
        };
      });
    };
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
    package = mkOption {
      type = types.package;
      default = doom-emacs;
      description = "The emacs package that is being used";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { pkgs, ... }: {
      # Prepare the service.
      home.file.".emacs.d/init.el".text = ''
        (load "default.el")
      '';
      services.emacs = {
        enable = true;
        package = doom-emacs;
        client.enable = true;
      };

      # Add another .desktop entry
      home.packages = [ doom-emacs extra-desktop ];
    };
    # Give mu4e what it needs
    cookie.mail-client.enable = true;
  };
}
