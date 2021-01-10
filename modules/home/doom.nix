{ pkgs, ... }:

let
  emacs-overlay = builtins.fetchTarball {
    url =
      "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
  };
in {
  nixpkgs.overlays = [ (import emacs-overlay) ];

  home.file.".doom.d".source = ./doom-conf;
  # we cant just symlink bc stupid doom binary wants to mutate ~/.emacs.d
  # this seems to break, just git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d && doom sync
  # home.activation = {
  #   doomEmacs = ''
  #     if [[ ! -f ~/.emacs.d ]]; then
  #       cp -r --no-preserve=ownership,mode ${doom-repo}/ ~/.emacs.d
  #       chmod +x ~/.emacs.d/bin/*
  #       ~/.emacs.d/bin/doom sync
  #     fi
  #   '';
  # };

  home.sessionPath = [ "~/.emacs.d/bin" ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };
}
