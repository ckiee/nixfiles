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
  ];
  sources = import ../../nix/sources.nix;
  doom-emacs = pkgs.callPackage sources.doom-emacs {
    doomPrivateDir = ../../ext/doom-conf;
    extraConfig = ''
      (setq exec-path (append exec-path '( ${
        concatMapStringsSep " " (x: ''"${x}/bin"'') extraBins
      } )))
    '';
  };
in {
  options.cookie.doom-emacs = {
    enable = mkEnableOption "Enables the Nixified Doom Emacs";
  };

  config = mkIf cfg.enable {
    home.packages = [ doom-emacs ];
    home.file.".emacs.d/init.el".text = ''
      (load "default.el")
    '';
  };
}
