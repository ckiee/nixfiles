{ sources, lib, config, pkgs, ... }:

with lib;
let
  cfg = config.cookie.doom-emacs;
  mu = pkgs.callPackage ./mu.nix {};
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
    # (texlive.combine {
    #   # LaTeX with org mode!
    #   inherit (texlive)
    #     scheme-medium wrapfig capt-of collection-langother ucs
    #     collection-fontsextra collection-fontsrecommended;
    # })
    gopls # Go LSP
    clang-tools # for clang-format and clangd (LSP)
    python3Packages.black # Python formatter
    html-tidy # HTML/SVG/Web formatter
    pandoc # markdown previewing (SPC m p in markdown-mode)
    elmPackages.elm # Elm
    elmPackages.elm-format # Elm
    pyright # Python LSP
    sumneko-lua-language-server # Lua (see config.org)
    racket-minimal # Racket LSP
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
    mu
  ];
  extraBinsElisp = ''
    (setq exec-path (append exec-path '( ${
      concatMapStringsSep " " (x: ''"${x}/bin"'') extraBins
    } )))
    (setenv "PATH" (concat (getenv "PATH") ":${
      concatMapStringsSep ":" (x: "${x}/bin") extraBins
    }"))
  '';

  extraDesktop = pkgs.writeTextFile {
    # theres a special helper for .desktop entries but i'm lazy and this works!
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
  emacsOverlay = (import
    sources.${if cfg.standalone then "emacs-overlay" else "emacs-overlay-prev"})
    pkgs pkgs;

  # https://github.com/nix-community/nix-doom-emacs/issues/60#issuecomment-1083630633
  tangledPrivateDir = pkgs.runCommand "tangled-doom-private" {
    passAsFile = [ "extraBinsElisp" ];
    inherit extraBinsElisp;
  } ''
    mkdir -p $out
    cd $out
    cp -rv ${./config}/. .
    rm {config,packages}.el
    ${baseEmacs}/bin/emacs --batch -Q -l org config.org -f org-babel-tangle $out
    mv config.el{,.orig}
    cat $extraBinsElispPath config.el.orig > config.el
    rm config.el.orig
    rm config.org
  '';

  baseEmacs = if !cfg.standalone then
    emacsOverlay.emacsNativeComp.override {
      # TODO so jank.. if this works we should copy the whole derivation..
      harfbuzz = pkgs.harfbuzz.overrideAttrs (prev: rec {
        version = "7.0.1";
        src = pkgs.fetchurl {
          url =
            "https://github.com/harfbuzz/harfbuzz/releases/download/${version}/harfbuzz-${version}.tar.xz";
          hash = "sha256-LPTT2PIlAHURmQo2o0GV8NZWLKVt8KiwiFs4KDeUgZk=";
        };
      });
      withXwidgets = true;
      withGTK3 = true;
    }
  else
    pkgs.emacs-gtk;

  doomEmacs = let
    mkDoom = configPath: emacs:
      pkgs.callPackage sources.nix-doom-emacs {
        doomPrivateDir = configPath;
        extraPackages = epkgs: [ mu ];
        bundledPackages = false;
        emacsPackages = emacsOverlay.emacsPackagesFor emacs;
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
      };
  in mkDoom tangledPrivateDir baseEmacs;
in {
  options.cookie.doom-emacs = {
    enable = mkEnableOption "Doom Emacs, Nix-managed by default";
    standalone = mkEnableOption "unmanaged Doom Emacs";
    package = mkOption {
      type = types.package;
      default = if cfg.standalone then baseEmacs else doomEmacs;
      description = "The emacs package that is being used";
      readOnly = true;
    };
    config = mkOption {
      type = types.package;
      default = extraBinsElisp; # HACK, should be abstracted.
      description = "The active Doom user config";
      readOnly = true;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Give mu4e what it needs
      cookie.mail-client.enable = true;

      home-manager.users.ckie = { pkgs, ... }: {
        home.packages = [
          extraDesktop
          mu # for CLI usage
        ];
      };
    })

    (mkIf (cfg.enable && !cfg.standalone) {
      home-manager.users.ckie = { pkgs, ... }: {
        # Prepare the service.
        services.emacs = {
          enable = true;
          package = doomEmacs;
          client.enable = true;
        };

        home.packages = [ doomEmacs ];
      };
    })
    (mkIf (cfg.enable && cfg.standalone) {
      home-manager.users.ckie = { pkgs, ... }: {
        services.emacs = {
          enable = true;
          package = baseEmacs;
          client.enable = true;
        };
        home.packages = [ baseEmacs ];
        xdg.configFile."doom".source = tangledPrivateDir;
      };
    })
  ];
}
