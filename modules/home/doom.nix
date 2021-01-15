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
  home.activation = {
    doomEmacs = ''
      if [[ ! -d ~/.emacs.d ]]; then
        git clone "https://github.com/hlissner/doom-emacs.git" ~/.emacs.d
      fi
      ~/.emacs.d/bin/doom sync
    '';
  };

  home.sessionPath = [ "~/.emacs.d/bin" ];

  # doom emacs wants these
  home.packages = with pkgs; [ shellcheck ripgrep jq fd ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };
}
