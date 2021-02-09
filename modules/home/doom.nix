{ pkgs, ... }:

let
  emacs-overlay = (builtins.fetchGit {
    url = "https://github.com/nix-community/emacs-overlay.git";
    rev = "d963d900925cbda9c679e8d3c0c2d225d2b0ae82";
    ref = "master";
  });
in {
  nixpkgs.overlays = [ (import emacs-overlay) ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [ epkgs.vterm ];
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
  ];

}
